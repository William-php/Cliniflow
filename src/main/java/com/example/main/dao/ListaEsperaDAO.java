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
import com.example.main.utils.Conexao;

public class ListaEsperaDAO {
	
	public static HashSet<ListaEspera> getListaEsperaByConsulta(int idConsulta) throws Exception {
		return new HashSet<>();
	}
	
	public static HashSet<ListaEspera> getListaEsperaByPaciente(int idPaciente) throws Exception {
		return new HashSet<>();
	}

	public static List<Map<String, Object>> getDetalhesFilaPaciente(int idPaciente) throws Exception {
		Connection conexao = Conexao.conectar();
		
		//faz a busca detalhada de todas as listas de espera ativas que o paciente está cadastrado
		String sql = "SELECT listas_espera.id_lista_espera, listas_espera.posicao_lista_espera, "
				+ "consultas.data_hora_consulta_inicio, perfis.id_perfil AS medico_id, "
				+ "usuarios.nome_usuario, usuarios.sobrenome_usuario "
				+ "FROM listas_espera "
				+ "JOIN consultas ON consultas.id_consulta = listas_espera.consulta "
				+ "JOIN perfis ON perfis.id_perfil = consultas.medico "
				+ "JOIN usuarios ON usuarios.id_usuario = perfis.usuario "
				+ "WHERE listas_espera.paciente = ? AND listas_espera.status_lista_espera = 'Ativa' "
				+ "ORDER BY consultas.data_hora_consulta_inicio ASC";
		
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setInt(1, idPaciente);
		ResultSet rs = stmt.executeQuery();
		
		List<Map<String, Object>> listaDetalhada = new ArrayList<>();
		
		while (rs.next()) {
			Map<String, Object> item = new HashMap<>();
			item.put("idListaEspera", rs.getInt("id_lista_espera"));
			item.put("posicao", rs.getInt("posicao_lista_espera"));
			item.put("idMedico", rs.getInt("medico_id")); // Salva o ID do médico
			item.put("nomeMedico", "Dr(a). " + rs.getString("nome_usuario") + " " + rs.getString("sobrenome_usuario"));
			
			java.sql.Timestamp ts = rs.getTimestamp("data_hora_consulta_inicio");
			if (ts != null) {
				item.put("dataHora", ts.toLocalDateTime());
			}
			listaDetalhada.add(item);
		}
		
		conexao.close();
		return listaDetalhada;
	}
	
	public static boolean entrarListaEspera(int idPaciente, int idConsultaOcupada) throws Exception {
        Connection conexao = Conexao.conectar();
        
        String sqlPos = "SELECT MAX(posicao_lista_espera) as max_pos FROM listas_espera WHERE consulta = ?";
        PreparedStatement stmtPos = conexao.prepareStatement(sqlPos);
        stmtPos.setInt(1, idConsultaOcupada);
        ResultSet rsPos = stmtPos.executeQuery();
        
        int novaPosicao = 1;
        if (rsPos.next()) {
            int maxPos = rsPos.getInt("max_pos");
            if (maxPos > 0) {
                novaPosicao = maxPos + 1;
            }
        }
        stmtPos.close();
        
        String sql = "INSERT INTO listas_espera (consulta, paciente, posicao_lista_espera, status_lista_espera) VALUES (?, ?, ?, 'Ativa')";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idConsultaOcupada);
        stmt.setInt(2, idPaciente);
        stmt.setInt(3, novaPosicao);
        
        int linhas = stmt.executeUpdate();
        stmt.close();
        conexao.close();
        return linhas > 0;
    }

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

    public static List<Map<String, Object>> getFilasAtivasAdmin() throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT c.id_consulta, c.data_hora_consulta_inicio, " +
                     "pm.id_perfil AS medico_id, um.nome_usuario AS med_nome, um.sobrenome_usuario AS med_sobrenome, " +
                     "COUNT(le.id_lista_espera) as qtd_pacientes " +
                     "FROM listas_espera le " +
                     "JOIN consultas c ON le.consulta = c.id_consulta " +
                     "JOIN perfis pm ON c.medico = pm.id_perfil " +
                     "JOIN usuarios um ON pm.usuario = um.id_usuario " +
                     "WHERE le.status_lista_espera = 'Ativa' " +
                     "GROUP BY c.id_consulta, c.data_hora_consulta_inicio, pm.id_perfil, um.nome_usuario, um.sobrenome_usuario " +
                     "ORDER BY c.data_hora_consulta_inicio ASC";
                     
        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();
        
        List<Map<String, Object>> lista = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> map = new HashMap<>();
            map.put("idConsulta", rs.getInt("id_consulta"));
            map.put("idMedico", rs.getInt("medico_id"));
            map.put("nomeMedico", "Dr(a). " + rs.getString("med_nome") + " " + rs.getString("med_sobrenome"));
            map.put("qtdPacientes", rs.getInt("qtd_pacientes"));
            
            java.sql.Timestamp ts = rs.getTimestamp("data_hora_consulta_inicio");
            if (ts != null) map.put("dataHora", ts.toLocalDateTime());
            
            lista.add(map);
        }
        conexao.close();
        return lista;
    }

    public static List<Map<String, Object>> getPacientesFilaAdmin(int idConsulta) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT le.id_lista_espera, le.posicao_lista_espera, le.paciente AS id_paciente, " +
                     "up.nome_usuario, up.sobrenome_usuario " +
                     "FROM listas_espera le " +
                     "JOIN perfis pp ON le.paciente = pp.id_perfil " +
                     "JOIN usuarios up ON pp.usuario = up.id_usuario " +
                     "WHERE le.consulta = ? AND le.status_lista_espera = 'Ativa' " +
                     "ORDER BY le.posicao_lista_espera ASC";
                     
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idConsulta);
        ResultSet rs = stmt.executeQuery();
        
        List<Map<String, Object>> lista = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> map = new HashMap<>();
            map.put("idListaEspera", rs.getInt("id_lista_espera"));
            map.put("posicao", rs.getInt("posicao_lista_espera"));
            map.put("idPaciente", rs.getInt("id_paciente"));
            map.put("nomePaciente", rs.getString("nome_usuario") + " " + rs.getString("sobrenome_usuario"));
            lista.add(map);
        }
        conexao.close();
        return lista;
    }

    public static void encerrarFilaCompleta(int idConsulta) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "DELETE FROM listas_espera WHERE consulta = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idConsulta);
        stmt.executeUpdate();
        conexao.close();
    }

    public static void removerPacienteReordenar(int idListaEspera, int idConsulta, int posicaoAtual) throws Exception {
        Connection conexao = Conexao.conectar();
        
        String sqlDel = "DELETE FROM listas_espera WHERE id_lista_espera = ?";
        PreparedStatement stmtDel = conexao.prepareStatement(sqlDel);
        stmtDel.setInt(1, idListaEspera);
        stmtDel.executeUpdate();
        
        String sqlUpd = "UPDATE listas_espera SET posicao_lista_espera = posicao_lista_espera - 1 " +
                        "WHERE consulta = ? AND posicao_lista_espera > ?";
        PreparedStatement stmtUpd = conexao.prepareStatement(sqlUpd);
        stmtUpd.setInt(1, idConsulta);
        stmtUpd.setInt(2, posicaoAtual);
        stmtUpd.executeUpdate();
        
        conexao.close();
    }

    public static void alocarVagaParaPaciente(int idConsulta, int idPaciente, int idListaEspera, int posicaoAtual) throws Exception {
        Connection conexao = Conexao.conectar();
        
        String sql = "UPDATE consultas SET paciente = ?, status_consulta = 'AGENDADA' WHERE id_consulta = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idPaciente);
        stmt.setInt(2, idConsulta);
        stmt.executeUpdate();
        conexao.close();
        
        removerPacienteReordenar(idListaEspera, idConsulta, posicaoAtual);
    }
    
    public static boolean promoverPrimeiroDaFila(int idConsulta) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT id_lista_espera, paciente, posicao_lista_espera FROM listas_espera " +
                     "WHERE consulta = ? AND status_lista_espera = 'Ativa' " +
                     "ORDER BY posicao_lista_espera ASC LIMIT 1";
        
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idConsulta);
        ResultSet rs = stmt.executeQuery();
        
        boolean temFila = false;
        int idListaEspera = 0, idPaciente = 0, posicaoAtual = 0;
        
        if (rs.next()) {
            temFila = true;
            idListaEspera = rs.getInt("id_lista_espera");
            idPaciente = rs.getInt("paciente");
            posicaoAtual = rs.getInt("posicao_lista_espera");
        }
        
        stmt.close();
        conexao.close();
        
        if (temFila) {
            alocarVagaParaPaciente(idConsulta, idPaciente, idListaEspera, posicaoAtual);
            return true;
        }
        
        return false;
    }
}