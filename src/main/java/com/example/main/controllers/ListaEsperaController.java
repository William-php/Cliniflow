package com.example.main.controllers;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.example.main.dao.ListaEsperaDAO;
import com.example.main.models.Perfil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "lista-espera", urlPatterns = "/minha-lista-espera")
public class ListaEsperaController extends HttpServlet {
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String acao = request.getParameter("acao");
		
		if ("sair_fila".equals(acao)) {
			try {
				HttpSession session = request.getSession();
				Perfil perfil = (Perfil) session.getAttribute("usuarioLogado");
				
				if(perfil != null) {
					// Pega o ID específico vindo do formulário e deleta SÓ ELE
					int idFila = Integer.parseInt(request.getParameter("id_lista_espera"));
					boolean sucesso = ListaEsperaDAO.sairDaFila(idFila, perfil.getIdPerfil());
					
					response.sendRedirect("minha-lista-espera");
				} else {
					response.sendRedirect("index.jsp");
				}
			} catch (Exception e) {
				e.printStackTrace();
				response.sendRedirect("minha-lista-espera?erro=excecao");
			}
		}
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String action = request.getServletPath();
		switch (action) {
			case "/minha-lista-espera":				
				carregarListaDeEsperaDoPaciente(request, response);
				break;
			default:
				response.sendRedirect("index.jsp");
				break;
		}
	}
	
	public static void carregarListaDeEsperaDoPaciente(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil perfil = (Perfil) session.getAttribute("usuarioLogado");
		
		if(perfil != null) {
			int idPerfil = perfil.getIdPerfil();		
			try {
				// Usa o novo método inteligente que retorna o Map com as Datas
				List<Map<String, Object>> filasDetalhadas = ListaEsperaDAO.getDetalhesFilaPaciente(idPerfil);
				request.setAttribute("filasDetalhadas", filasDetalhadas);
				
				request.getRequestDispatcher("lista-espera.jsp").forward(request, response);
			} catch (Exception e) {
				e.printStackTrace();
			}
		} else {
			response.sendRedirect("index.jsp");
		}
	}
}