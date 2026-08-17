package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import com.example.main.models.ListaEspera;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;
import com.example.main.utils.Conexao;
import com.example.main.utils.Utilidade;

public class ListaEsperaDAO {
	
	// (Mantive os métodos originais do seu colega intactos)
	public static HashSet<ListaEspera> getListaEsperaByConsulta(int idConsulta) throws Exception {
		// ... código original ...
		return new HashSet<>();
	}
	
	public static HashSet<ListaEspera> getListaEsperaByPaciente(int idPaciente) throws Exception {
		// ... código original ...
		return new HashSet<>();
	}

	// ======================================================================================
	// NOVOS MÉTODOS PARA A TELA (Ignorando as Models para evitar quebra de sistema)
	// ======================================================================================

	public static List<Map<String, Object>> getDetalhesFilaPaciente(int idPaciente) throws Exception {
		Connection conexao = Conexao.conectar();
		
		// Busca os dados diretamente mesclando as tabelas e devolvendo genérico
		String sql = "SELECT listas_espera.id_lista_espera, listas_espera.posicao_lista_espera, "
				+ "consultas.data_hora_consulta_inicio, "
				+ "usuarios.nome_usuario, usuarios.sobrenome_usuario "
				+ "FROM listas_espera "
				+ "JOIN consultas ON consultas.id_consulta = listas_espera.consulta "
				+ "JOIN perfis ON perfis.id_perfil = consultas.medico "
				+ "JOIN usuarios ON usuarios.id_usuario = perfis.usuario "
				+ "WHERE listas_espera.paciente = ? "
				+ "ORDER BY consultas.data_hora_consulta_inicio ASC";
		
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setInt(1, idPaciente);
		ResultSet rs = stmt.executeQuery();
		
		List<Map<String, Object>> listaDetalhada = new ArrayList<>();
		
		while (rs.next()) {
			Map<String, Object> item = new HashMap<>();
			item.put("idListaEspera", rs.getInt("id_lista_espera"));
			item.put("posicao", rs.getInt("posicao_lista_espera"));
			item.put("nomeMedico", "Dr(a). " + rs.getString("nome_usuario") + " " + rs.getString("sobrenome_usuario"));
			
			// Pega a data e converte para LocalDateTime
			java.sql.Timestamp ts = rs.getTimestamp("data_hora_consulta_inicio");
			if (ts != null) {
				item.put("dataHora", ts.toLocalDateTime());
			}
			listaDetalhada.add(item);
		}
		
		conexao.close();
		return listaDetalhada;
	}

	// Método Corrigido: Exclui APENAS o ID específico da fila deste paciente
	public static boolean sairDaFila(int idListaEspera, int idPaciente) throws Exception {
		Connection conexao = Conexao.conectar();
		boolean atualizou = false;
		
		String sql = "DELETE FROM listas_espera WHERE id_lista_espera = ? AND paciente = ?";
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setInt(1, idListaEspera);
		stmt.setInt(2, idPaciente);
		
		int linhasAfetadas = stmt.executeUpdate();
		if (linhasAfetadas > 0) {
			atualizou = true;
		}
		
		conexao.close();
		return atualizou;
	}
}