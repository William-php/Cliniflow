package com.example.main.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.example.main.dao.ListaEsperaDAO;
import com.example.main.models.Perfil;
import com.example.main.utils.Conexao;

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
		
		if (usuarioLogado != null && usuarioLogado.getUsuario() != null && usuarioLogado.getUsuario().isAdmUsuario()) {
			try {
				int qtdListas = ListaEsperaDAO.getFilasAtivasAdmin().size();
				request.setAttribute("listasEsperaAtivas", qtdListas);
				
				int pacientes = 0;
				int medicos = 0;
				int consultasHoje = 0;
				
				try (Connection conexao = Conexao.conectar()) {
					// card total pacientes
					PreparedStatement ps1 = conexao.prepareStatement("SELECT COUNT(*) FROM perfis WHERE tipo_perfil = 'PACIENTE'");
					ResultSet rs1 = ps1.executeQuery();
					if (rs1.next()) pacientes = rs1.getInt(1);
					
					// card total medicos
					PreparedStatement ps2 = conexao.prepareStatement("SELECT COUNT(*) FROM perfis WHERE tipo_perfil = 'MEDICO'");
					ResultSet rs2 = ps2.executeQuery();
					if (rs2.next()) medicos = rs2.getInt(1);
					
					// card consultas hoje
					PreparedStatement ps3 = conexao.prepareStatement("SELECT COUNT(*) FROM consultas WHERE DATE(data_hora_consulta_inicio) = CURDATE() AND UPPER(status_consulta) != 'CANCELADA'");
					ResultSet rs3 = ps3.executeQuery();
					if (rs3.next()) consultasHoje = rs3.getInt(1);
				}
				
				request.setAttribute("totalPacientes", pacientes);
				request.setAttribute("totalMedicos", medicos);
				request.setAttribute("consultasHoje", consultasHoje);

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