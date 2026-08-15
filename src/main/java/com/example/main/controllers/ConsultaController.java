package com.example.main.controllers;

import java.io.IOException;
import java.util.HashSet;

import com.example.main.dao.ConsultaDAO;
import com.example.main.models.Consulta;
import com.example.main.models.Perfil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "consulta", urlPatterns = {"/consultas", "/minhas-consultas"})
public class ConsultaController extends HttpServlet {
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String action = request.getServletPath();
		
		switch (action) {
			case "/consultas":
				carregarDadosNaTelaInicial(request, response);
				break;
			case "/minhas-consultas":
				carregarMinhasConsultas(request, response);
				break;			
			default:
				break;
		}
		
	}
	
	public static void carregarDadosNaTelaInicial(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		HttpSession session = request.getSession();
		Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
		HashSet<Consulta> consultasPorUsuarioLogado = new HashSet<Consulta>();
		
		if (usuarioLogado != null) {
			try {					
				consultasPorUsuarioLogado = ConsultaDAO.getConsultaByPacienteId(usuarioLogado.getIdPerfil());				
				request.setAttribute("consultasUsuarioLogado", consultasPorUsuarioLogado);
				request.getRequestDispatcher("home.jsp").forward(request, response);
			} catch (Exception e) {
				consultasPorUsuarioLogado = null;
				e.printStackTrace();
			}
						
		}
	}
	
	public static void carregarMinhasConsultas(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
		
		HashSet<Consulta> consultasPorUsuarioLogado = new HashSet<Consulta>();
		
		if (usuarioLogado != null) {
			try {					
				consultasPorUsuarioLogado = ConsultaDAO.getConsultaByPacienteId(usuarioLogado.getIdPerfil());
				System.out.println("teste");
				request.setAttribute("consultasUsuarioLogado", consultasPorUsuarioLogado);
				request.getRequestDispatcher("minhas-consultas.jsp").forward(request, response);
			} catch (Exception e) {
				consultasPorUsuarioLogado = null;
				e.printStackTrace();
			}						
		}
	}
	
	
}
