package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.example.main.utils.Conexao;

public class MedicoAgendaDAO {
	
    public static List<LocalDate> getDiasComAgenda(int idMedico) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT DISTINCT DATE(data_hora_consulta_inicio) as dia " +
                     "FROM consultas " +
                     "WHERE medico = ? AND DATE(data_hora_consulta_inicio) >= CURDATE() " +
                     "ORDER BY dia ASC LIMIT 15";
                     
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idMedico);
        ResultSet rs = stmt.executeQuery();
        
        List<LocalDate> dias = new ArrayList<>();
        while (rs.next()) {
            dias.add(rs.getDate("dia").toLocalDate());
        }
        conexao.close();
        return dias;
    }

    // busca as consultas de um dia especifico para montar timeline
    public static List<Map<String, Object>> getConsultasDoDia(int idMedico, LocalDate data) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT c.id_consulta, c.data_hora_consulta_inicio, c.status_consulta, " +
                     "u.nome_usuario, u.sobrenome_usuario " +
                     "FROM consultas c " +
                     "LEFT JOIN perfis p ON c.paciente = p.id_perfil " +
                     "LEFT JOIN usuarios u ON p.usuario = u.id_usuario " +
                     "WHERE c.medico = ? AND DATE(c.data_hora_consulta_inicio) = ? " +
                     "ORDER BY c.data_hora_consulta_inicio ASC";
                     
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idMedico);
        stmt.setDate(2, java.sql.Date.valueOf(data));
        ResultSet rs = stmt.executeQuery();
        
        List<Map<String, Object>> lista = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> map = new HashMap<>();
            map.put("idConsulta", rs.getInt("id_consulta"));
            
            java.sql.Timestamp ts = rs.getTimestamp("data_hora_consulta_inicio");
            if (ts != null) map.put("dataHora", ts.toLocalDateTime());
            
            String status = rs.getString("status_consulta");
            map.put("status", status != null ? status : "LIVRE");
            
            String nome = rs.getString("nome_usuario");
            if (nome != null) {
                map.put("nomePaciente", nome + " " + rs.getString("sobrenome_usuario"));
            } else {
                map.put("nomePaciente", null);
            }
            
            lista.add(map);
        }
        conexao.close();
        return lista;
    }

    public static List<LocalDate> getDiasComConsultaNoMes(int idMedico, int mes, int ano) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT DISTINCT DATE(data_hora_consulta_inicio) as dia " +
                     "FROM consultas " +
                     "WHERE medico = ? AND MONTH(data_hora_consulta_inicio) = ? AND YEAR(data_hora_consulta_inicio) = ? " +
                     "ORDER BY dia ASC";
                     
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idMedico);
        stmt.setInt(2, mes);
        stmt.setInt(3, ano);
        ResultSet rs = stmt.executeQuery();
        
        List<LocalDate> dias = new ArrayList<>();
        while (rs.next()) {
            dias.add(rs.getDate("dia").toLocalDate());
        }
        conexao.close();
        return dias;
    }
}