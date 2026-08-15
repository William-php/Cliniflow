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
		atualizarUsuario(request, response);
	}
	
	public static void atualizarUsuario(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil perfil = (Perfil) session.getAttribute("usuarioLogado");
		System.out.println("Bateu?");
		try {
			Usuario usuarioAtualizado = removerUsuarioPerfil(perfil);
			usuarioAtualizado.setNomeUsuario(request.getParameter("nome_usuario"));
			usuarioAtualizado.setSobrenomeUsuario(request.getParameter("sobrenome_usuario"));
			usuarioAtualizado.setEmailUsuario(request.getParameter("email_usuario"));
			int responseBD = UsuarioDAO.putUsuarioById(usuarioAtualizado);
			if (responseBD != 0) {
				perfil.setUsuario(usuarioAtualizado);
				session.setAttribute("usuariAtualizado", perfil);
				request.getRequestDispatcher("editar-perfil.jsp").forward(request, response);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}
	
	public static Usuario removerUsuarioPerfil(Perfil p) throws Exception {
		Usuario usuario = p.getUsuario();
		if (usuario == null) throw new Exception();
		return usuario;
	}
	
}
