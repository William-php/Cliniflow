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

@WebServlet(name = "perfil", urlPatterns = {"/editar-perfil", "/deletar-conta"})
public class PerfilController extends HttpServlet {
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String action = request.getServletPath();
		
		if ("/editar-perfil".equals(action)) {
			HttpSession session = request.getSession();
			Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
			
			if (usuarioLogado != null) {
				request.getRequestDispatcher("editar-perfil.jsp").forward(request, response);
			} else {
				response.sendRedirect("index.jsp");
			}
		} else {
			response.sendRedirect("index.jsp");
		}
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String action = request.getServletPath();
		
		if ("/deletar-conta".equals(action)) {
			HttpSession session = request.getSession();
			Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
			
			if (usuarioLogado != null && usuarioLogado.getUsuario() != null) {
				try {
					int idUsuario = usuarioLogado.getUsuario().getIdUsuario();
					
					// Inativa o usuário no banco de dados
					boolean inativado = PerfilDAO.inativarUsuario(idUsuario);
					
					if (inativado) {
						// Destri a sessão e manda para o login
						session.invalidate();
						response.sendRedirect("index.jsp?conta=desativada");
					} else {
						response.sendRedirect("editar-perfil.jsp?erro=falha_inativar");
					}
				} catch (Exception e) {
					e.printStackTrace();
					response.sendRedirect("editar-perfil.jsp?erro=excecao");
				}
			} else {
				response.sendRedirect("index.jsp");
			}
		}
	}
}