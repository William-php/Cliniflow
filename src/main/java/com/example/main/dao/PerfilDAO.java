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
	// Método para inativar a conta do usuário (Deletar lógico)
		public static boolean inativarUsuario(int idUsuario) throws Exception {
			Connection conexao = Conexao.conectar();
			boolean sucesso = false;
			
			// Atualiza o campo status_usuario para 'Inativo' (ou 0, dependendo do seu banco, ajustado para string conforme citação do usuário)
			String sql = "UPDATE usuarios SET status_usuario = 'Inativo' WHERE id_usuario = ?";
			PreparedStatement stmt = conexao.prepareStatement(sql);
			stmt.setInt(1, idUsuario);
			
			int linhasAfetadas = stmt.executeUpdate();
			if (linhasAfetadas > 0) {
				sucesso = true;
			}
			
			conexao.close();
			return sucesso;
		}
		// Novo método para o Painel do Administrador listar todos os usuários
		// Novo método para o Painel do Administrador listar todos os usuários (ignorando o próprio admin)
		public static HashSet<Perfil> getTodosUsuariosComPerfil(int idAdminLogado) throws Exception {
			Connection conexao = Conexao.conectar();
			
			// Busca todo mundo, EXCETO o admin que está fazendo a requisição
			String sql = "SELECT usuarios.*, perfis.* FROM usuarios JOIN perfis ON usuarios.id_usuario = perfis.usuario "
					+ "WHERE usuarios.id_usuario != ? "
					+ "ORDER BY usuarios.nome_usuario ASC";
			
			PreparedStatement stmt = conexao.prepareStatement(sql);
			stmt.setInt(1, idAdminLogado); // Bloqueia o ID do admin logado
			
			ResultSet rs = stmt.executeQuery();
			
			HashSet<Perfil> lista = new HashSet<Perfil>();
			
			while (rs.next()) {
				Usuario u = Utilidade.gerarUsuarioComDadosDoBD(rs);
				Perfil p = Utilidade.gerarPerfilComDadosDoBD(rs);
				p.setUsuario(u);
				lista.add(p);
			}
			
			conexao.close();
			return lista;
		}
}
