package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;

import com.example.main.utils.Conexao;

public class MedicoDashboardDAO {

    // 1. Busca o próximo paciente agendado para o médico
    public static Object[] getProximaConsulta(int idMedico) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT up.nome_usuario, up.sobrenome_usuario, c.data_hora_consulta_inicio " +
                     "FROM consultas c " +
                     "JOIN perfis pp ON c.paciente = pp.id_perfil " +
                     "JOIN usuarios up ON pp.usuario = up.id_usuario " +
                     "WHERE c.medico = ? AND c.data_hora_consulta_inicio >= NOW() " +
                     "AND c.status_consulta = 'AGENDADA' " +
                     "ORDER BY c.data_hora_consulta_inicio ASC LIMIT 1";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idMedico);
        ResultSet rs = stmt.executeQuery();

        Object[] result = null;
        if (rs.next()) {
            result = new Object[2];
            result[0] = rs.getString("nome_usuario") + " " + rs.getString("sobrenome_usuario");
            java.sql.Timestamp ts = rs.getTimestamp("data_hora_consulta_inicio");
            if (ts != null) result[1] = ts.toLocalDateTime();
        }
        conexao.close();
        return result;
    }

    // 2. Conta os atendimentos do Dia, do Mês ou os Concluídos
    public static int getContagemConsultas(int idMedico, String tipo) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "";
        
        if ("DIA".equals(tipo)) {
            sql = "SELECT COUNT(*) FROM consultas WHERE medico = ? AND DATE(data_hora_consulta_inicio) = CURDATE() AND status_consulta != 'Cancelada'";
        } else if ("MES".equals(tipo)) {
            sql = "SELECT COUNT(*) FROM consultas WHERE medico = ? AND MONTH(data_hora_consulta_inicio) = MONTH(CURDATE()) AND YEAR(data_hora_consulta_inicio) = YEAR(CURDATE()) AND status_consulta != 'Cancelada'";
        } else if ("CONCLUIDAS".equals(tipo)) {
            // SÓ CONTA QUANDO ATENDER!
            sql = "SELECT COUNT(*) FROM consultas WHERE medico = ? AND MONTH(data_hora_consulta_inicio) = MONTH(CURDATE()) AND YEAR(data_hora_consulta_inicio) = YEAR(CURDATE()) AND status_consulta IN ('Realizada', 'Concluida', 'REALIZADA', 'CONCLUIDA')";
        }

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idMedico);
        ResultSet rs = stmt.executeQuery();
        int count = 0;
        if (rs.next()) count = rs.getInt(1);
        
        conexao.close();
        return count;
    }

    // 3. Monta o Array de dias pro Calendário: ['2026-08-20', '2026-08-25']
    public static String getDatasComAgendaJSON(int idMedico) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT DISTINCT DATE(data_hora_consulta_inicio) as data_agenda FROM consultas WHERE medico = ? AND status_consulta = 'AGENDADA'";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idMedico);
        ResultSet rs = stmt.executeQuery();

        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        while (rs.next()) {
            if (!first) json.append(",");
            json.append("'").append(rs.getDate("data_agenda").toString()).append("'");
            first = false;
        }
        json.append("]");
        conexao.close();
        return json.toString();
    }

    // 4. Monta o Array do Gráfico Anual somando por meses: [10, 15, 20, 0, 5...]
    public static String getDadosGraficoAnualJSON(int idMedico) throws Exception {
        Connection conexao = Conexao.conectar();
        
        // MÁGICA REAL: Agora o gráfico SÓ sobe se o status for Realizada ou Concluida!
        String sql = "SELECT MONTH(data_hora_consulta_inicio) as mes, COUNT(*) as qtd " +
                     "FROM consultas " +
                     "WHERE medico = ? AND YEAR(data_hora_consulta_inicio) = YEAR(CURDATE()) " +
                     "AND status_consulta IN ('Realizada', 'Concluida', 'REALIZADA', 'CONCLUIDA') " +
                     "GROUP BY MONTH(data_hora_consulta_inicio)";
                     
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idMedico);
        ResultSet rs = stmt.executeQuery();

        int[] meses = new int[12];
        while (rs.next()) {
            int mes = rs.getInt("mes");
            int qtd = rs.getInt("qtd");
            meses[mes - 1] = qtd; // O array começa em 0 (Janeiro)
        }
        conexao.close();

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < 12; i++) {
            json.append(meses[i]);
            if (i < 11) json.append(",");
        }
        json.append("]");
        return json.toString();
    }
}