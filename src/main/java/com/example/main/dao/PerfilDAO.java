package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashSet;

import com.example.main.models.Perfil;
import com.example.main.models.Usuario;
import com.example.main.utils.Conexao;
import com.example.main.utils.Utilidade;

public class PerfilDAO {
	public static Perfil getPerfilLogin(String emailUsuario, String senhaUsuario) throws Exception {
		Connection conexao = Conexao.conectar();
		String sql = "SELECT usuarios.*, perfis.* FROM usuarios JOIN perfis ON usuarios.id_usuario = perfis.usuario "
				+ " WHERE email_usuario = ? AND senha_usuario = ?";
	
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setString(1, emailUsuario);
		stmt.setString(2, senhaUsuario);
		
		ResultSet rs = stmt.executeQuery();
		
		Perfil perfil = null;
		
		while (rs.next()) {
			Usuario u = Utilidade.gerarUsuarioComDadosDoBD(rs);
			perfil = Utilidade.gerarPerfilComDadosDoBD(rs);			
			perfil.setUsuario(u);
		}
		
		return perfil;
	}
	
//	public static HashSet<Perfil> getMedicosByEspecialidade(String especialidade) {
//		Connection conexao = Conexao.conectar();
//		String sql = "SELECT *, perfis.tipo_perfil, usuarios.nome_usuario FROM  especialidades_medico \n"
//				+ "JOIN perfis ON perfis.id_perfil = especialidades_medico.medico \n"
//				+ "JOIN usuarios ON usuarios.id_usuario = perfis.usuario \n"
//				+ "WHERE especialidades_medico.especialidade  = ?";
//		//PreparedStatement stmt = 
//		return null;
//	}
}
