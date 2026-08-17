package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashSet;

import com.example.main.models.Consulta;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;
import com.example.main.utils.Conexao;
import com.example.main.utils.Utilidade;

public class ConsultaDAO {
	
	// 1. Método original (Histórico Completo)
	public static HashSet<Consulta> getConsultaByPacienteId(int idPaciente) throws Exception {
		Connection conexao = Conexao.conectar();
		String sqlConsulta = "SELECT consultas.*, perfis.*, usuarios.* FROM consultas " 
				+ "JOIN perfis ON consultas.medico = perfis.id_perfil "
				+ "JOIN usuarios ON perfis.usuario = usuarios.id_usuario "
				+ "WHERE paciente = ?";
		PreparedStatement stmt = conexao.prepareStatement(sqlConsulta);
		stmt.setInt(1, idPaciente);
		ResultSet rs = stmt.executeQuery();
		HashSet<Consulta> consultasDoPaciente = new HashSet<Consulta>();
		while (rs.next()) {
			Usuario u = Utilidade.gerarUsuarioComDadosDoBD(rs);
			Perfil p = Utilidade.gerarPerfilComDadosDoBD(rs);
			//inserindo usuário
			p.setUsuario(u);
			Consulta c = Utilidade.gerarConsultaComDadosDoBD(rs);
			c.setMedicoConsulta(p);
			consultasDoPaciente.add(c);
		}
		conexao.close();
		return consultasDoPaciente;
	} 
	
	// 2. NOVO: Método para buscar a Próxima Consulta (aproveitando o Utilidade!)
	public static Consulta getProximaConsultaByPacienteId(int idPaciente) throws Exception {
		Connection conexao = Conexao.conectar();
		String sqlConsulta = "SELECT consultas.*, perfis.*, usuarios.* FROM consultas " 
				+ "JOIN perfis ON consultas.medico = perfis.id_perfil "
				+ "JOIN usuarios ON perfis.usuario = usuarios.id_usuario "
				+ "WHERE paciente = ? AND status_consulta = 'Agendada' AND data_hora_consulta_inicio >= NOW() "
				+ "ORDER BY data_hora_consulta_inicio ASC LIMIT 1";
		PreparedStatement stmt = conexao.prepareStatement(sqlConsulta);
		stmt.setInt(1, idPaciente);
		ResultSet rs = stmt.executeQuery();
		
		Consulta c = null;
		if (rs.next()) {
			Usuario u = Utilidade.gerarUsuarioComDadosDoBD(rs);
			Perfil p = Utilidade.gerarPerfilComDadosDoBD(rs);
			p.setUsuario(u);
			c = Utilidade.gerarConsultaComDadosDoBD(rs);
			c.setMedicoConsulta(p);
		}
		conexao.close();
		return c;
	}
	
	// 3. NOVO: Método para buscar as Estatísticas dos Cards
	public static int countConsultasByFiltro(int idPaciente, String filtro) throws Exception {
		Connection conexao = Conexao.conectar();
		int count = 0;
		String sql = "SELECT COUNT(*) AS total FROM consultas WHERE paciente = ? AND status_consulta = 'Agendada'";
		
		if ("DIA".equals(filtro)) {
			sql += " AND DATE(data_hora_consulta_inicio) = CURDATE()";
		} else if ("MES".equals(filtro)) {
			sql += " AND MONTH(data_hora_consulta_inicio) = MONTH(CURDATE()) AND YEAR(data_hora_consulta_inicio) = YEAR(CURDATE())";
		}
		
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setInt(1, idPaciente);
		ResultSet rs = stmt.executeQuery();
		if (rs.next()) {
			count = rs.getInt("total");
		}
		conexao.close();
		return count;
	}
	
	// 4. NOVO: Método para salvar um agendamento novo
		public static boolean agendarNovaConsulta(int idPaciente, int idMedico, String data, String horarioInicio) throws Exception {
			Connection conexao = Conexao.conectar();
			boolean sucesso = false;
			
			// Formata as strings para o padrão DateTime do MySQL
			String inicioStr = data + " " + horarioInicio + ":00";
			java.time.LocalTime horaInicio = java.time.LocalTime.parse(horarioInicio);
			java.time.LocalTime horaFim = horaInicio.plusMinutes(30);
			String fimStr = data + " " + horaFim.toString() + ":00";

			// 1. Verifica se já existe uma consulta nesse horário
			String sqlCheck = "SELECT id_consulta FROM consultas WHERE medico = ? AND data_hora_consulta_inicio = ? AND status_consulta = 'Agendada'";
			PreparedStatement stmtCheck = conexao.prepareStatement(sqlCheck);
			stmtCheck.setInt(1, idMedico);
			stmtCheck.setString(2, inicioStr);
			ResultSet rsCheck = stmtCheck.executeQuery();

			if (rsCheck.next()) {
				// HORÁRIO OCUPADO: Insere o paciente na Lista de Espera
				int idConsultaExistente = rsCheck.getInt("id_consulta");
				
				String sqlPos = "SELECT COUNT(*) + 1 AS proxima_pos FROM listas_espera WHERE consulta = ?";
				PreparedStatement stmtPos = conexao.prepareStatement(sqlPos);
				stmtPos.setInt(1, idConsultaExistente);
				ResultSet rsPos = stmtPos.executeQuery();
				int posicao = 1;
				if(rsPos.next()) posicao = rsPos.getInt("proxima_pos");
				
				String sqlFila = "INSERT INTO listas_espera (consulta, paciente, posicao_lista_espera, status_lista_espera) VALUES (?, ?, ?, 'Ativa')";
				PreparedStatement stmtFila = conexao.prepareStatement(sqlFila);
				stmtFila.setInt(1, idConsultaExistente);
				stmtFila.setInt(2, idPaciente);
				stmtFila.setInt(3, posicao);
				stmtFila.executeUpdate();
				sucesso = true;
			} else {
				// HORÁRIO LIVRE: Agenda a consulta normalmente
				String sqlInsert = "INSERT INTO consultas (paciente, medico, status_consulta, data_hora_consulta_inicio, data_hora_consulta_fim) VALUES (?, ?, 'Agendada', ?, ?)";
				PreparedStatement stmtInsert = conexao.prepareStatement(sqlInsert);
				stmtInsert.setInt(1, idPaciente);
				stmtInsert.setInt(2, idMedico);
				stmtInsert.setString(3, inicioStr);
				stmtInsert.setString(4, fimStr);
				stmtInsert.executeUpdate();
				sucesso = true;
			}
			
			conexao.close();
			return sucesso;
		}
		// 5. NOVO: Método para Cancelar uma Consulta
		public static boolean cancelarConsulta(int idConsulta) throws Exception {
			Connection conexao = Conexao.conectar();
			boolean atualizou = false;
			
			String sql = "UPDATE consultas SET status_consulta = 'Cancelada' WHERE id_consulta = ?";
			PreparedStatement stmt = conexao.prepareStatement(sql);
			stmt.setInt(1, idConsulta);
			
			int linhasAfetadas = stmt.executeUpdate();
			if (linhasAfetadas > 0) {
				atualizou = true;
			}
			
			conexao.close();
			return atualizou;
		}
}