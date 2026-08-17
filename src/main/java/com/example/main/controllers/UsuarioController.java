package com.example.main.controllers;

import java.io.IOException;

import com.example.main.dao.UsuarioDAO;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "usuario", urlPatterns = "/usuario")
public class UsuarioController extends HttpServlet {
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// O método agora retorna true se salvou, ou false se deu erro
		boolean sucesso = atualizarUsuario(request, response);
		
		if (sucesso) {
			// Agora sim! Ele redireciona para a home com a flag de mensagem
			response.sendRedirect("home?atualizado=true");
		} else {
			// Se der erro, ele devolve para a tela de perfil
			response.sendRedirect("editar-perfil?erro=falha_atualizar");
		}
	}
	
	public static boolean atualizarUsuario(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil perfil = (Perfil) session.getAttribute("usuarioLogado");
		System.out.println("Processando atualização de usuário...");
		
		try {
			Usuario usuarioAtualizado = removerUsuarioPerfil(perfil);
			usuarioAtualizado.setNomeUsuario(request.getParameter("nome_usuario"));
			usuarioAtualizado.setSobrenomeUsuario(request.getParameter("sobrenome_usuario"));
			usuarioAtualizado.setEmailUsuario(request.getParameter("email_usuario"));
			
			int responseBD = UsuarioDAO.putUsuarioById(usuarioAtualizado);
			
			if (responseBD != 0) {
				perfil.setUsuario(usuarioAtualizado);
				
				// CORREÇÃO: O nome da sessão TEM que ser 'usuarioLogado' para o cabeçalho atualizar na hora!
				session.setAttribute("usuarioLogado", perfil);
				
				return true; // Sucesso!
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return false; // Falha!
	}
	
	public static Usuario removerUsuarioPerfil(Perfil p) throws Exception {
		Usuario usuario = p.getUsuario();
		if (usuario == null) throw new Exception();
		return usuario;
	}
	
}