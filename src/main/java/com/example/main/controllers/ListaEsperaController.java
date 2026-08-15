package com.example.main.controllers;

import java.io.IOException;
import java.util.HashSet;

import com.example.main.dao.ListaEsperaDAO;
import com.example.main.models.ListaEspera;
import com.example.main.models.Perfil;
import com.mysql.cj.Session;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "lista-espera", urlPatterns = "/minha-lista-espera")
public class ListaEsperaController extends HttpServlet {
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		String idConsultaString = request.getParameter("id_consulta");
//		int idConsulta = Integer.parseInt(idConsultaString);		
//		try {
//			HashSet<ListaEspera> listaEspera = ListaEsperaDAO.getListaEsperaByConsulta(idConsulta);
//			request.setAttribute("listaEspera", listaEspera);
//			
//			request.getRequestDispatcher("/lista-espera.jsp").forward(request, response);
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
		
		String action = request.getServletPath();
		switch (action) {
			case "/minha-lista-espera":				
				carregarListaDeEsperaDoPaciente(request, response);
				break;
			default:
				break;
		}
	}
	
	public static void carregarListaDeEsperaDoPaciente(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil perfil = (Perfil) session.getAttribute("usuarioLogado");
		int idPerfil = perfil.getIdPerfil();		
		try {
			HashSet<ListaEspera> minhasListasEspera = ListaEsperaDAO.getListaEsperaByPaciente(idPerfil);
			for (ListaEspera l:minhasListasEspera) {
				System.out.println(l.getMedicoListaEspera().getUsuario().getNomeUsuario() + l.getMedicoListaEspera().getUsuario().getSobrenomeUsuario());				
			}
			request.setAttribute("minhasListasEspera", minhasListasEspera);
			request.getRequestDispatcher("lista-espera.jsp").forward(request, response);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
