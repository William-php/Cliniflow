package com.example.main.controllers;

import java.io.IOException;

import com.example.main.dao.PerfilDAO;
import com.example.main.models.Perfil;

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
		
		try {
			Perfil usuarioLogado = PerfilDAO.getPerfilLogin(email, password);
			
			if (usuarioLogado != null && usuarioLogado.getUsuario() != null) {
				
				String status = usuarioLogado.getUsuario().getStatusUsuario().name();
				if ("INATIVO".equalsIgnoreCase(status) || "DESATIVADA".equalsIgnoreCase(status)) {
					response.sendRedirect(request.getContextPath() + "/index.jsp?erro=conta_inativa");
					return;
				}
				
				HttpSession session = request.getSession();
				session.setAttribute("usuarioLogado", usuarioLogado);
				
				if (usuarioLogado.getUsuario().isAdmUsuario()) {
					response.sendRedirect(request.getContextPath() + "/admin-home");
				} else if ("MEDICO".equalsIgnoreCase(usuarioLogado.getTipoPerfil().name())) {
					response.sendRedirect(request.getContextPath() + "/medico-home");
				} else {
					response.sendRedirect(request.getContextPath() + "/home");
				}
				
			} else {
				response.sendRedirect(request.getContextPath() + "/index.jsp?erro=credenciais");
			}
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/index.jsp?erro=excecao");
		}
	}
}