package com.example.main.controllers;

import java.io.IOException;

import com.example.main.models.Perfil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "adminUsuarios", urlPatterns = {"/admin-usuarios"})
public class AdminUsuarioController extends HttpServlet {
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
		
		// Validação de segurança: Só admin acessa
		if (usuarioLogado != null && usuarioLogado.getUsuario() != null && usuarioLogado.getUsuario().isAdmUsuario()) {
			try {
				// Captura o ID do Administrador logado
				int idAdmin = usuarioLogado.getUsuario().getIdUsuario();
				
				// Busca os dados reais do banco PASSANDO O ID do admin para ser ignorado na lista
				java.util.HashSet<Perfil> listaUsuarios = com.example.main.dao.PerfilDAO.getTodosUsuariosComPerfil(idAdmin);
				request.setAttribute("listaUsuarios", listaUsuarios);
				
				// Direciona para a tela
				request.getRequestDispatcher("admin-usuarios.jsp").forward(request, response);
			} catch (Exception e) {
				e.printStackTrace();
				response.sendRedirect("admin-home");
			}
		} else {
			response.sendRedirect("index.jsp");
		}
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// Futuras ações de bloquear/editar usuários via POST virão aqui
		doGet(request, response);
	}
}