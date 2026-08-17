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

@WebServlet(name = "consulta", urlPatterns = {"/home", "/minhas-consultas"})
public class ConsultaController extends HttpServlet {
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String acao = request.getParameter("acao");
		
		// Intercepta a requisição de cancelamento
		if ("cancelar".equals(acao)) {
			try {
				int idConsulta = Integer.parseInt(request.getParameter("id_consulta"));
				
				// Chama o DAO para mudar o status para Cancelada
				boolean sucesso = ConsultaDAO.cancelarConsulta(idConsulta);
				
				if (sucesso) {
					response.sendRedirect(request.getContextPath() + "/minhas-consultas");
				} else {
					response.sendRedirect(request.getContextPath() + "/minhas-consultas?erro=nao_foi_possivel_cancelar");
				}
			} catch (Exception e) {
				e.printStackTrace();
				response.sendRedirect(request.getContextPath() + "/minhas-consultas?erro=excecao");
			}
		}
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String action = request.getServletPath();
		
		switch (action) {
			case "/home":
				carregarDadosNaTelaInicial(request, response);
				break;
			case "/minhas-consultas":
				carregarMinhasConsultas(request, response);
				break;			
			default:
				response.sendRedirect("index.jsp");
				break;
		}
	}
	
	public static void carregarDadosNaTelaInicial(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
		HashSet<Consulta> consultasPorUsuarioLogado = new HashSet<Consulta>();
		
		if (usuarioLogado != null) {
			try {					
				// 1. Busca a lista do histórico (O que o seu colega já tinha feito)
				consultasPorUsuarioLogado = ConsultaDAO.getConsultaByPacienteId(usuarioLogado.getIdPerfil());				
				request.setAttribute("consultasUsuarioLogado", consultasPorUsuarioLogado);
				
				// 2. Busca a próxima consulta para exibir no card superior
				Consulta proximaConsulta = ConsultaDAO.getProximaConsultaByPacienteId(usuarioLogado.getIdPerfil());
				if (proximaConsulta != null && proximaConsulta.getMedicoConsulta() != null) {
					String nomeMedico = "Dr(a). " + proximaConsulta.getMedicoConsulta().getUsuario().getNomeUsuario();
					String dataFormatada = proximaConsulta.getDataHoraInicioConsulta().toString().replace("T", " às ");
					request.setAttribute("proxMedico", nomeMedico);
					request.setAttribute("proxData", dataFormatada);
				}
				
				// 3. Busca as estatísticas para preencher os três cards centrais
				request.setAttribute("consultasDia", ConsultaDAO.countConsultasByFiltro(usuarioLogado.getIdPerfil(), "DIA"));
				request.setAttribute("consultasMes", ConsultaDAO.countConsultasByFiltro(usuarioLogado.getIdPerfil(), "MES"));
				request.setAttribute("totalConsultas", ConsultaDAO.countConsultasByFiltro(usuarioLogado.getIdPerfil(), "TOTAL"));
				
				request.getRequestDispatcher("home.jsp").forward(request, response);
			} catch (Exception e) {
				e.printStackTrace();
				// Em caso de erro, ainda manda para a home para não dar tela branca
				request.getRequestDispatcher("home.jsp").forward(request, response);
			}
		} else {
			response.sendRedirect("index.jsp");
		}
	}
	
	public static void carregarMinhasConsultas(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
		HashSet<Consulta> consultasPorUsuarioLogado = new HashSet<Consulta>();
		
		if (usuarioLogado != null) {
			try {					
				consultasPorUsuarioLogado = ConsultaDAO.getConsultaByPacienteId(usuarioLogado.getIdPerfil());
				request.setAttribute("consultasUsuarioLogado", consultasPorUsuarioLogado);
				request.getRequestDispatcher("minhas-consultas.jsp").forward(request, response);
			} catch (Exception e) {
				e.printStackTrace();
			}						
		} else {
			response.sendRedirect("index.jsp");
		}
	}
}