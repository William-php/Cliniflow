package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;

import com.example.main.enums.Sexo;
import com.example.main.enums.StatusUsuario;
import com.example.main.models.Usuario;
import com.example.main.utils.Conexao;
import com.example.main.utils.Utilidade;

public class UsuarioDAO {
	
	public static Usuario gerarUsuarioComDadosDoBD(ResultSet rs) throws SQLException {
		LocalDateTime dataHora = Utilidade.converterDatasParaLocalDateTime(rs.getString("data_nascimento_usuario"));
		Usuario u = new Usuario(
					rs.getString("nome_usuario"),
					rs.getString("sobrenome_usuario"),
					dataHora,
					rs.getString("cpf_usuario"),
					rs.getString("email_usuario"),
					rs.getString("senha_usuario"),
					StatusUsuario.ATIVO,
					Sexo.MASCULINO,
					rs.getBoolean("adm_usuario"),
					rs.getString("crm_usuario")
				);
		return u;
	}
	
	public static ArrayList<Usuario> getUsuarios() throws Exception {
		Connection conexao = Conexao.conectar(); //se repete muito
		
		String sql = "SELECT * FROM usuarios";
		
		PreparedStatement statement = conexao.prepareStatement(sql); //se repete muito
		ResultSet rs = statement.executeQuery();
		
		ArrayList<Usuario> listaUsuarios = new ArrayList<Usuario>();
		
		while (rs.next() ) {
			Usuario u = gerarUsuarioComDadosDoBD(rs);
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
			usuario = gerarUsuarioComDadosDoBD(rs);			
		}
		
		return usuario;
	}
	
	public static int postUsuario(Usuario novoUsuario) throws Exception {
		Connection conexao = Conexao.conectar();
		
		String sql = "INSERT INTO usuarios ("
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
		
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setString(1, novoUsuario.getNomeUsuario());
		stmt.setString(2, novoUsuario.getSobrenomeUsuario());
		stmt.setObject(3, novoUsuario.getDataNascimentoUsuario());
		stmt.setString(4, novoUsuario.getCpfUsuario());
		stmt.setString(5, novoUsuario.getEmailUsuario());
		stmt.setString(6, novoUsuario.getSenhaUsuario());
		stmt.setString(7, novoUsuario.getStatusUsuario().name());
		stmt.setString(8, novoUsuario.getSexoUsuario().name());
		stmt.setBoolean(9, novoUsuario.isAdmUsuario());
		stmt.setString(10, novoUsuario.getCrmUsuario());
		
		int response = stmt.executeUpdate();
		conexao.close();
		return response;
	}
	
	public static int deleteUsuarioById(int idUsuario) throws Exception {
		Connection conexao = Conexao.conectar();
		String sql = "DELETE FROM usuarios WHERE id_usuario = ?";
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setInt(1, idUsuario);
		
		int response = stmt.executeUpdate();
		
		return response;
	}

}
