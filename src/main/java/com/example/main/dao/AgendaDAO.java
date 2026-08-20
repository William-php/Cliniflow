package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashSet;

import com.example.main.models.AgendaMedico;
import com.example.main.models.Especialidade;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;
import com.example.main.utils.Conexao;

public class AgendaDAO {

    // lista as agendas cadastradas unindo com perfis e especialidades
    public static HashSet<AgendaMedico> getTodasAgendas() throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT a.*, u.nome_usuario, u.sobrenome_usuario, e.tipo_especialidade, e.nome_especialidade " +
                "FROM agenda_medico a " +
                "JOIN perfis p ON a.medico = p.id_perfil " +
                "JOIN usuarios u ON p.usuario = u.id_usuario " +
                "JOIN especialidades e ON a.especialidade = e.id_especialidade " +
                "ORDER BY a.data_agenda DESC, a.hora_inicio ASC";
        
        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();
        HashSet<AgendaMedico> lista = new HashSet<AgendaMedico>();
        
        while (rs.next()) {
            AgendaMedico agenda = new AgendaMedico();
            agenda.setIdAgenda(rs.getInt("id_agenda"));
            agenda.setDataAgenda(rs.getDate("data_agenda").toLocalDate());
            agenda.setHoraInicio(rs.getTime("hora_inicio").toLocalTime());
            agenda.setHoraFim(rs.getTime("hora_fim").toLocalTime());
            agenda.setStatusAgenda(rs.getString("status_agenda"));
            
            Usuario u = new Usuario();
            u.setNomeUsuario(rs.getString("nome_usuario"));
            u.setSobrenomeUsuario(rs.getString("sobrenome_usuario"));
            
            Perfil med = new Perfil();
            med.setIdPerfil(rs.getInt("medico"));
            med.setUsuario(u);
            agenda.setMedico(med);
            
            Especialidade esp = new Especialidade();
            esp.setIdEspecialidade(rs.getInt("especialidade"));
            esp.setNomeEspecialidade(rs.getString("nome_especialidade"));
            agenda.setEspecialidade(esp);
            
            lista.add(agenda);
        }
        
        conexao.close();
        return lista;
    }

    public static void inserirAgenda(AgendaMedico agenda) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "INSERT INTO agenda_medico (medico, especialidade, data_agenda, hora_inicio, hora_fim, status_agenda) VALUES (?, ?, ?, ?, ?, 'Disponivel')";
        
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, agenda.getMedico().getIdPerfil());
        stmt.setInt(2, agenda.getEspecialidade().getIdEspecialidade());
        stmt.setDate(3, java.sql.Date.valueOf(agenda.getDataAgenda()));
        stmt.setTime(4, java.sql.Time.valueOf(agenda.getHoraInicio()));
        stmt.setTime(5, java.sql.Time.valueOf(agenda.getHoraFim()));
        
        stmt.executeUpdate();
        conexao.close();
    }
}