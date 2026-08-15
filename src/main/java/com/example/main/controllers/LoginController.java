package com.example.main.controllers;

import java.io.IOException;
import java.util.Optional;

import com.example.main.dao.PerfilDAO;
import com.example.main.dao.UsuarioDAO;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "login", urlPatterns = "/login")
public class LoginController extends HttpServlet {
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String email = request.getParameter("email_usuario");
		String password = request.getParameter("senha_usuario");
		Perfil usuarioLogado = null;
		
		try {
			usuarioLogado = PerfilDAO.getPerfilLogin(email, password);
			
			if (usuarioLogado != null) {
				HttpSession session = request.getSession();
				session.setAttribute("usuarioLogado", usuarioLogado);
				response.sendRedirect(request.getContextPath() + "/consultas");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		
		
	}
}
