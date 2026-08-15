package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;

import com.example.main.enums.TipoEspecialidade;
import com.example.main.models.Especialidade;
import com.example.main.utils.Conexao;

public class EspecialidadeDAO {
	public static Especialidade gerarEspecialidadesComDadosBD(ResultSet rs) throws SQLException {
		TipoEspecialidade tipo = TipoEspecialidade.valueOf(rs.getString("tipo_especialidade").toUpperCase());
		Especialidade e = new Especialidade(tipo, rs.getString("nome_especialidade"));
		return e;
	}
	public static HashSet<Especialidade> getEspecialidades() throws Exception {
		Connection conexao = Conexao.conectar();
		String sql = "SELECT * FROM especialidades";
		
		PreparedStatement stmt = conexao.prepareStatement(sql);
		
		ResultSet rs = stmt.executeQuery();
		HashSet<Especialidade> listaEspecialidades = new HashSet<Especialidade>();
		while (rs.next()) {
			Especialidade e = gerarEspecialidadesComDadosBD(rs);
			listaEspecialidades.add(e);
		}		
		return listaEspecialidades;
	}
}
