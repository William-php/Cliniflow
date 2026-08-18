package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import com.example.main.enums.TipoEspecialidade;
import com.example.main.models.Especialidade;
import com.example.main.utils.Conexao;

public class EspecialidadeDAO {
    
    public static Especialidade gerarEspecialidadesComDadosBD(ResultSet rs) throws SQLException {
        TipoEspecialidade tipo = TipoEspecialidade.valueOf(rs.getString("tipo_especialidade").toUpperCase());
        Especialidade e = new Especialidade(tipo, rs.getString("nome_especialidade"));
        e.setIdEspecialidade(rs.getInt("id_especialidade"));
        return e;
    }
    
    public static HashSet<Especialidade> getEspecialidades() throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT * FROM especialidades ORDER BY tipo_especialidade ASC";
        
        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();
        HashSet<Especialidade> listaEspecialidades = new HashSet<Especialidade>();
        
        while (rs.next()) {
            Especialidade e = gerarEspecialidadesComDadosBD(rs);
            listaEspecialidades.add(e);
        }
        conexao.close();
        return listaEspecialidades;
    }

    public static List<Integer> getIdsEspecialidadesDoMedico(int idPerfilMedico) throws Exception {
        Connection conexao = Conexao.conectar();
        String sql = "SELECT especialidade FROM especialidades_medico WHERE medico = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idPerfilMedico);
        ResultSet rs = stmt.executeQuery();
        
        List<Integer> ids = new ArrayList<>();
        while (rs.next()) {
            ids.add(rs.getInt("especialidade"));
        }
        conexao.close();
        return ids;
    }

    public static void atualizarEspecialidadesDoMedico(int idPerfilMedico, String[] idsEspecialidades) throws Exception {
        Connection conexao = Conexao.conectar();
        
        String sqlDelete = "DELETE FROM especialidades_medico WHERE medico = ?";
        PreparedStatement stmtDel = conexao.prepareStatement(sqlDelete);
        stmtDel.setInt(1, idPerfilMedico);
        stmtDel.executeUpdate();
        
        if (idsEspecialidades != null && idsEspecialidades.length > 0) {
            String sqlInsert = "INSERT INTO especialidades_medico (medico, especialidade) VALUES (?, ?)";
            PreparedStatement stmtIns = conexao.prepareStatement(sqlInsert);
            for (String idEsp : idsEspecialidades) {
                stmtIns.setInt(1, idPerfilMedico);
                stmtIns.setInt(2, Integer.parseInt(idEsp));
                stmtIns.executeUpdate();
            }
        }
        conexao.close();
    }
}