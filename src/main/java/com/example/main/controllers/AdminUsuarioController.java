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

		if (usuarioLogado != null && usuarioLogado.getUsuario() != null && usuarioLogado.getUsuario().isAdmUsuario()) {
			try {
				int idAdmin = usuarioLogado.getUsuario().getIdUsuario();
				
				java.util.HashSet<Perfil> listaUsuarios = com.example.main.dao.PerfilDAO.getTodosUsuariosComPerfil(idAdmin);
				request.setAttribute("listaUsuarios", listaUsuarios);
				
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
		String acao = request.getParameter("acao");
		
		if ("toggle_status".equals(acao)) {
			try {
				int idUsuario = Integer.parseInt(request.getParameter("id_usuario"));
				String novoStatusStr = request.getParameter("novo_status");
				
				com.example.main.models.Usuario usuario = com.example.main.dao.UsuarioDAO.getUsuarioById(idUsuario);
				
				if (usuario != null) {
					if ("ATIVO".equals(novoStatusStr)) {
						usuario.setStatusUsuario(com.example.main.enums.StatusUsuario.ATIVO);
					} else {
						usuario.setStatusUsuario(com.example.main.enums.StatusUsuario.DESATIVADO);
					}
					
					com.example.main.dao.UsuarioDAO.putUsuarioById(usuario);
				}
				
				response.sendRedirect("admin-usuarios");
			} catch (Exception e) {
				e.printStackTrace();
				response.sendRedirect("admin-usuarios");
			}
		}
	}
}