package com.example.main.controllers;

import java.io.IOException;

import com.example.main.models.Perfil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "admin", urlPatterns = {"/admin-home"})
public class AdminController extends HttpServlet {
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String action = request.getServletPath();
		
		switch (action) {
			case "/admin-home":
				carregarDashboardAdmin(request, response);
				break;
			default:
				response.sendRedirect("index.jsp");
				break;
		}
	}
	
	public static void carregarDashboardAdmin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
		
		// Aqui depois podemos adicionar uma validação mais forte: 
		// if (usuarioLogado != null && usuarioLogado.getTipoPerfil() == TipoPerfil.ADMIN)
		if (usuarioLogado != null) {
			try {
				// No futuro, chamaremos os DAOs aqui para popular os cards com totais de pacientes, médicos, etc.
				request.getRequestDispatcher("admin-home.jsp").forward(request, response);
			} catch (Exception e) {
				e.printStackTrace();
				response.sendRedirect("index.jsp");
			}
		} else {
			response.sendRedirect("index.jsp");
		}
	}
}