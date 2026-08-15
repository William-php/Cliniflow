package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.util.ArrayList;

import com.example.main.enums.Sexo;
import com.example.main.enums.StatusUsuario;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;
import com.example.main.utils.Conexao;
import com.example.main.utils.Utilidade;

public class UsuarioDAO {
	
	public static ArrayList<Usuario> getUsuarios() throws Exception {
		Connection conexao = Conexao.conectar(); //se repete muito
		
		String sql = "SELECT * FROM usuarios";
		
		PreparedStatement statement = conexao.prepareStatement(sql); //se repete muito
		ResultSet rs = statement.executeQuery();
		
		ArrayList<Usuario> listaUsuarios = new ArrayList<Usuario>();
		
		while (rs.next() ) {
			Usuario u = Utilidade.gerarUsuarioComDadosDoBD(rs);
			listaUsuarios.add(u);
		}
		
		conexao.close();		
		return listaUsuarios;
	}
	
	public static Usuario getUsuarioById(int idUsuario) throws Exception {
		Connection conexao = Conexao.conectar();
		
		String sql = "SELECT * FROM usuarios WHERE id_usuario = ?";
		PreparedStatement statement = conexao.prepareStatement(sql);
		statement.setInt(1, idUsuario);
		ResultSet rs = statement.executeQuery();
		
		Usuario usuario = null;
		
		while (rs.next()) {
			usuario = Utilidade.gerarUsuarioComDadosDoBD(rs);			
		}
		
		return usuario;
	}
	
	//Retornar dados do usuário no login
	public static Usuario getUsuarioByEmailAndSenha(String emailUsuario, String senhaUsuario) throws Exception {
		Connection conexao = Conexao.conectar();
		String sql = "SELECT * FROM usuarios JOIN  WHERE email_usuario = ? AND senha_usuario = ?";
		
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setString(1, emailUsuario);
		stmt.setString(2, senhaUsuario);
		
		ResultSet rs = stmt.executeQuery();
		Usuario usuario = null;
		while (rs.next()) {
			usuario = Utilidade.gerarUsuarioComDadosDoBD(rs);
		}
		return usuario;
	}
	
	public static int postUsuario(Usuario novoUsuario, Perfil perfil) throws Exception {
		Connection conexao = Conexao.conectar();
		
		String sqlUsuario = "INSERT INTO usuarios ("
				+ "	nome_usuario,"
				+ "	sobrenome_usuario,"
				+ "	data_nascimento_usuario,"
				+ "	cpf_usuario,"
				+ "	email_usuario,"
				+ "	senha_usuario,"
				+ "	status_usuario,"
				+ "	sexo_usuario,"
				+ "	adm_usuario,"
				+ " crm_usuario"
				+ ") VALUES ("
				+ "	?,"
				+ "	?,"
				+ "	?,"
				+ "	?,"
				+ "	?,"
				+ "	?,"
				+ "	?,"
				+ "	?,"
				+ "	?,"
				+ " ?"
				+ ")";
		
		String sqlPerfil = "INSERT INTO perfis (tipo_perfil, usuario) VALUES (?, ?)";
		
		conexao.setAutoCommit(false);
		PreparedStatement stmtUsuario = conexao.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS);
		PreparedStatement stmtPerfil = conexao.prepareStatement(sqlPerfil);
		stmtUsuario.setString(1, novoUsuario.getNomeUsuario());
		stmtUsuario.setString(2, novoUsuario.getSobrenomeUsuario());
		stmtUsuario.setObject(3, novoUsuario.getDataNascimentoUsuario());
		stmtUsuario.setString(4, novoUsuario.getCpfUsuario());
		stmtUsuario.setString(5, novoUsuario.getEmailUsuario());
		stmtUsuario.setString(6, novoUsuario.getSenhaUsuario());
		stmtUsuario.setString(7, novoUsuario.getStatusUsuario().name());
		stmtUsuario.setString(8, novoUsuario.getSexoUsuario().name());
		stmtUsuario.setBoolean(9, novoUsuario.isAdmUsuario());
		stmtUsuario.setString(10, novoUsuario.getCrmUsuario());
		
		int responseUsuarioCriado = stmtUsuario.executeUpdate();
		int responsePerfilCriado = 0;
		if (responseUsuarioCriado != 0) {
			ResultSet generatedKeys = stmtUsuario.getGeneratedKeys();
			if (generatedKeys.next()) {
				int idUsuarioGerado = generatedKeys.getInt(1);
				stmtPerfil.setString(1, perfil.getTipoPerfil().name());
				stmtPerfil.setInt(2, idUsuarioGerado);
				
				responsePerfilCriado = stmtPerfil.executeUpdate();
			}
		}
		
		conexao.commit();
		conexao.close();
		return responsePerfilCriado;
	}
	
	public static int deleteUsuarioById(int idUsuario) throws Exception {
		Connection conexao = Conexao.conectar();
		String sql = "DELETE FROM usuarios WHERE id_usuario = ?";
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setInt(1, idUsuario);
		
		int response = stmt.executeUpdate();
		
		return response;
	}
	
	public static int putUsuarioById(Usuario usuarioAtualizado) throws Exception {
		Connection conexao = Conexao.conectar();
		String sql = "UPDATE usuarios "
				+ "SET "
				+ " nome_usuario = ?,"
				+ "	sobrenome_usuario = ?,"
				+ "	data_nascimento_usuario = ?,"
				+ "	cpf_usuario = ?,"
				+ "	email_usuario = ?,"
				+ "	senha_usuario = ?,"
				+ "	status_usuario = ?,"
				+ "	sexo_usuario = ?,"
				+ "	adm_usuario = ?,"
				+ " crm_usuario = ? "
				+ "WHERE id_usuario = ?";
		
		PreparedStatement stmt = conexao.prepareStatement(sql);
		
		stmt.setString(1, usuarioAtualizado.getNomeUsuario());
		stmt.setString(2, usuarioAtualizado.getSobrenomeUsuario());
		stmt.setObject(3, usuarioAtualizado.getDataNascimentoUsuario());
		stmt.setString(4, usuarioAtualizado.getCpfUsuario());
		stmt.setString(5, usuarioAtualizado.getEmailUsuario());
		stmt.setString(6, usuarioAtualizado.getSenhaUsuario());
		stmt.setString(7, usuarioAtualizado.getStatusUsuario().name());
		stmt.setString(8, usuarioAtualizado.getSexoUsuario().name());
		stmt.setBoolean(9, usuarioAtualizado.isAdmUsuario());
		stmt.setString(10, usuarioAtualizado.getCrmUsuario());
		stmt.setInt(11, usuarioAtualizado.getIdUsuario());
		
		int response = stmt.executeUpdate();
		return response;
	}

}
