package com.example.main.controllers;

import java.io.IOException;
import java.util.HashSet;

import com.example.main.dao.EspecialidadeDAO;
import com.example.main.models.Especialidade;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "agendamento", urlPatterns = "/agendamento")
public class AgendamentoController extends HttpServlet {
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("Testando post/agendamento");
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		carregarPaginaAgendamento(request, response);
	}
	
	public static void carregarPaginaAgendamento(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			HashSet<Especialidade> especialidades = EspecialidadeDAO.getEspecialidades();
			if (especialidades.size() != 0) {
				request.setAttribute("especialidades", especialidades);
				request.getRequestDispatcher("agendamento.jsp").forward(request, response);
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		 
	}
}
