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
			p.setUsuario(u);
			Consulta c = Utilidade.gerarConsultaComDadosDoBD(rs);
			c.setMedicoConsulta(p);
			consultasDoPaciente.add(c);
		}
		conexao.close();
		return consultasDoPaciente;
	} 
	
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
	
	public static boolean agendarNovaConsulta(int idPaciente, int idMedico, String data, String horarioInicio) throws Exception {
		Connection conexao = Conexao.conectar();
		boolean sucesso = false;
		
		String inicioStr = data + " " + horarioInicio + ":00";
		java.time.LocalTime horaInicio = java.time.LocalTime.parse(horarioInicio);
		java.time.LocalTime horaFim = horaInicio.plusMinutes(30);
		String fimStr = data + " " + horaFim.toString() + ":00";

		String sqlCheck = "SELECT id_consulta FROM consultas WHERE medico = ? AND data_hora_consulta_inicio = ? AND status_consulta = 'Agendada'";
		PreparedStatement stmtCheck = conexao.prepareStatement(sqlCheck);
		stmtCheck.setInt(1, idMedico);
		stmtCheck.setString(2, inicioStr);
		ResultSet rsCheck = stmtCheck.executeQuery();

		if (rsCheck.next()) {
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
	
	public static boolean cancelarConsulta(int idConsulta) throws Exception {
		Connection conexao = Conexao.conectar();
		
		//antes de cancelar, o sistema "guarda" quem era o dono da consulta
		String sqlSelect = "SELECT paciente, medico, data_hora_consulta_inicio, data_hora_consulta_fim FROM consultas WHERE id_consulta = ?";
		PreparedStatement stmtSel = conexao.prepareStatement(sqlSelect);
		stmtSel.setInt(1, idConsulta);
		ResultSet rs = stmtSel.executeQuery();
		
		int pacienteOriginal = 0;
		int medico = 0;
		java.sql.Timestamp inicio = null;
		java.sql.Timestamp fim = null;
		
		if (rs.next()) {
			pacienteOriginal = rs.getInt("paciente");
			medico = rs.getInt("medico");
			inicio = rs.getTimestamp("data_hora_consulta_inicio");
			fim = rs.getTimestamp("data_hora_consulta_fim");
		}
		stmtSel.close();

		String sql = "UPDATE consultas SET status_consulta = 'Cancelada' WHERE id_consulta = ?";
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setInt(1, idConsulta);
		int linhasAfetadas = stmt.executeUpdate();
		stmt.close();
		
		boolean atualizou = false;
		if (linhasAfetadas > 0) {
			atualizou = true;
			boolean filaAndou = ListaEsperaDAO.promoverPrimeiroDaFila(idConsulta);
			
			// para o pacienteOriginal nao perder o histórico, uma copia da cancelada
			if (filaAndou && pacienteOriginal > 0) {
				String sqlClone = "INSERT INTO consultas (paciente, medico, data_hora_consulta_inicio, data_hora_consulta_fim, status_consulta) VALUES (?, ?, ?, ?, 'Cancelada')";
				PreparedStatement stmtClone = conexao.prepareStatement(sqlClone);
				stmtClone.setInt(1, pacienteOriginal);
				stmtClone.setInt(2, medico);
				stmtClone.setTimestamp(3, inicio);
				stmtClone.setTimestamp(4, fim);
				stmtClone.executeUpdate();
				stmtClone.close();
			}
		}
		
		conexao.close();
		return atualizou;
	}
	
	public static java.util.HashSet<com.example.main.models.Consulta> getTodasConsultasAdmin() throws Exception {
        java.sql.Connection conexao = com.example.main.utils.Conexao.conectar();
        
        //trazer os dados da tabela de consultas cruzando as informações com as tabelas de perfis e usuários
        String sql = "SELECT c.*, " +
                     "pp.id_perfil AS pac_id_perfil, up.nome_usuario AS pac_nome, up.sobrenome_usuario AS pac_sobrenome, " +
                     "pm.id_perfil AS med_id_perfil, um.nome_usuario AS med_nome, um.sobrenome_usuario AS med_sobrenome " +
                     "FROM consultas c " +
                     "JOIN perfis pp ON c.paciente = pp.id_perfil " +
                     "JOIN usuarios up ON pp.usuario = up.id_usuario " +
                     "JOIN perfis pm ON c.medico = pm.id_perfil " +
                     "JOIN usuarios um ON pm.usuario = um.id_usuario " +
                     "ORDER BY c.data_hora_consulta_inicio DESC";
        
        java.sql.PreparedStatement stmt = conexao.prepareStatement(sql);
        java.sql.ResultSet rs = stmt.executeQuery();
        
        java.util.HashSet<com.example.main.models.Consulta> lista = new java.util.HashSet<>();
        
        while (rs.next()) {
            com.example.main.models.Consulta c = new com.example.main.models.Consulta();
            c.setIdConsulta(rs.getInt("id_consulta"));
            
            java.sql.Timestamp tsInicio = rs.getTimestamp("data_hora_consulta_inicio");
            if (tsInicio != null) c.setDataHoraInicioConsulta(tsInicio.toLocalDateTime());
            
            String status = rs.getString("status_consulta");
            if (status != null) {
                c.setStatusConsulta(com.example.main.enums.StatusConsulta.valueOf(status.toUpperCase()));
            }
            
            com.example.main.models.Perfil paciente = new com.example.main.models.Perfil();
            paciente.setIdPerfil(rs.getInt("pac_id_perfil")); 
            com.example.main.models.Usuario uPac = new com.example.main.models.Usuario();
            uPac.setNomeUsuario(rs.getString("pac_nome"));
            uPac.setSobrenomeUsuario(rs.getString("pac_sobrenome"));
            paciente.setUsuario(uPac);
            c.setPacienteConsulta(paciente);
            
            com.example.main.models.Perfil medico = new com.example.main.models.Perfil();
            medico.setIdPerfil(rs.getInt("med_id_perfil")); 
            com.example.main.models.Usuario uMed = new com.example.main.models.Usuario();
            uMed.setNomeUsuario(rs.getString("med_nome"));
            uMed.setSobrenomeUsuario(rs.getString("med_sobrenome"));
            medico.setUsuario(uMed);
            c.setMedicoConsulta(medico);
            
            lista.add(c);
        }
        
        conexao.close();
        return lista;
    }

    public static boolean atualizarStatusConsulta(int idConsulta, String novoStatus) throws Exception {
        java.sql.Connection conexao = com.example.main.utils.Conexao.conectar();
        
        int pacienteOriginal = 0, medico = 0;
        java.sql.Timestamp inicio = null, fim = null;
        
        if ("Cancelada".equalsIgnoreCase(novoStatus)) {
            String sqlSelect = "SELECT paciente, medico, data_hora_consulta_inicio, data_hora_consulta_fim FROM consultas WHERE id_consulta = ?";
            java.sql.PreparedStatement stmtSel = conexao.prepareStatement(sqlSelect);
            stmtSel.setInt(1, idConsulta);
            java.sql.ResultSet rs = stmtSel.executeQuery();
            if (rs.next()) {
                pacienteOriginal = rs.getInt("paciente");
                medico = rs.getInt("medico");
                inicio = rs.getTimestamp("data_hora_consulta_inicio");
                fim = rs.getTimestamp("data_hora_consulta_fim");
            }
            stmtSel.close();
        }

        String sql = "UPDATE consultas SET status_consulta = ? WHERE id_consulta = ?";
        java.sql.PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setString(1, novoStatus);
        stmt.setInt(2, idConsulta);
        int linhas = stmt.executeUpdate();
        stmt.close();
        
        // gatilho Clone para o paciente nao perder a consulta faltada no historico
        if (linhas > 0 && "Cancelada".equalsIgnoreCase(novoStatus)) {
            boolean filaAndou = ListaEsperaDAO.promoverPrimeiroDaFila(idConsulta);
            
            if (filaAndou && pacienteOriginal > 0) {
                String sqlClone = "INSERT INTO consultas (paciente, medico, data_hora_consulta_inicio, data_hora_consulta_fim, status_consulta) VALUES (?, ?, ?, ?, 'Cancelada')";
                java.sql.PreparedStatement stmtClone = conexao.prepareStatement(sqlClone);
                stmtClone.setInt(1, pacienteOriginal);
                stmtClone.setInt(2, medico);
                stmtClone.setTimestamp(3, inicio);
                stmtClone.setTimestamp(4, fim);
                stmtClone.executeUpdate();
                stmtClone.close();
            }
        }
        
        conexao.close();
        return linhas > 0;
    }
}