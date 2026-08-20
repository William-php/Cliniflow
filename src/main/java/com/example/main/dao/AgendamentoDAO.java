package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

import com.example.main.models.AgendaMedico;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;
import com.example.main.utils.Conexao;

public class AgendamentoDAO {

    // busca medicos que tem agenda para uma especialidade
    public static List<Perfil> getMedicosDisponiveisPorEspecialidade(int idEspecialidade) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT DISTINCT p.id_perfil, u.nome_usuario, u.sobrenome_usuario " +
                     "FROM agenda_medico a " +
                     "JOIN perfis p ON a.medico = p.id_perfil " +
                     "JOIN usuarios u ON p.usuario = u.id_usuario " +
                     "WHERE a.especialidade = ? AND a.data_agenda >= CURDATE() AND a.status_agenda = 'Disponivel'";
        
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idEspecialidade);
        ResultSet rs = stmt.executeQuery();
        
        List<Perfil> medicos = new ArrayList<>();
        while (rs.next()) {
            Perfil p = new Perfil();
            p.setIdPerfil(rs.getInt("id_perfil"));
            Usuario u = new Usuario();
            u.setNomeUsuario(rs.getString("nome_usuario"));
            u.setSobrenomeUsuario(rs.getString("sobrenome_usuario"));
            p.setUsuario(u);
            medicos.add(p);
        }
        conexao.close();
        return medicos;
    }

    public static List<String> getDatasDisponiveisMedico(int idMedico) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT DISTINCT data_agenda FROM agenda_medico " +
                     "WHERE medico = ? AND data_agenda >= CURDATE() AND status_agenda = 'Disponivel'";
        
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idMedico);
        ResultSet rs = stmt.executeQuery();
        
        List<String> datas = new ArrayList<>();
        while (rs.next()) {
            datas.add(rs.getDate("data_agenda").toString());
        }
        conexao.close();
        return datas;
    }

    public static List<AgendaMedico> getTurnosDoDia(int idMedico, LocalDate data) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT hora_inicio, hora_fim FROM agenda_medico " +
                     "WHERE medico = ? AND data_agenda = ? AND status_agenda = 'Disponivel'";
        
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idMedico);
        stmt.setDate(2, java.sql.Date.valueOf(data));
        ResultSet rs = stmt.executeQuery();
        
        List<AgendaMedico> turnos = new ArrayList<>();
        while (rs.next()) {
            AgendaMedico a = new AgendaMedico();
            a.setHoraInicio(rs.getTime("hora_inicio").toLocalTime());
            a.setHoraFim(rs.getTime("hora_fim").toLocalTime());
            turnos.add(a);
        }
        conexao.close();
        return turnos;
    }

    public static Integer getConsultaExistente(int idMedico, LocalDateTime dataHora) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT id_consulta FROM consultas " +
                     "WHERE medico = ? AND data_hora_consulta_inicio = ? " +
                     "AND UPPER(status_consulta) != 'CANCELADA'";
        
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idMedico);
        stmt.setTimestamp(2, java.sql.Timestamp.valueOf(dataHora));
        ResultSet rs = stmt.executeQuery();
        
        Integer idConsulta = null;
        if (rs.next()) {
            idConsulta = rs.getInt("id_consulta");
        }
        conexao.close();
        return idConsulta;
    }

    // salva a consulta
    public static void agendarConsulta(int idPaciente, int idMedico, LocalDateTime inicio) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "INSERT INTO consultas (paciente, medico, data_hora_consulta_inicio, data_hora_consulta_fim, status_consulta) VALUES (?, ?, ?, ?, 'Agendada')";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idPaciente);
        stmt.setInt(2, idMedico);
        stmt.setTimestamp(3, java.sql.Timestamp.valueOf(inicio));
        stmt.setTimestamp(4, java.sql.Timestamp.valueOf(inicio.plusMinutes(30)));
        stmt.executeUpdate();
        conexao.close();
    }

    // entra na lista de espera
    public static void entrarListaEspera(int idPaciente, int idConsultaOcupada) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "INSERT INTO listas_espera (consulta, paciente, posicao_lista_espera, status_lista_espera) VALUES (?, ?, 1, 'Aguardando')";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idConsultaOcupada);
        stmt.setInt(2, idPaciente);
        stmt.executeUpdate();
        conexao.close();
    }
}