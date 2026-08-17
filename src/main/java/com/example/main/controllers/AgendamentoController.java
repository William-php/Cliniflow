package com.example.main.controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashSet;

import com.example.main.dao.EspecialidadeDAO;
// Precisaremos importar o PerfilDAO e AgendaDAO logo em seguida
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
		// Importante: garantir que tem a importação do HttpSession e do Perfil no topo do arquivo
		jakarta.servlet.http.HttpSession session = request.getSession();
		com.example.main.models.Perfil usuarioLogado = (com.example.main.models.Perfil) session.getAttribute("usuarioLogado");

		if (usuarioLogado == null) {
			response.sendRedirect("index.jsp");
			return;
		}

		String idMedicoStr = request.getParameter("id_medico");
		String dataEscolhida = request.getParameter("data_escolhida");
		String horarioEscolhido = request.getParameter("horario_escolhido");

		if (idMedicoStr == null || dataEscolhida == null || horarioEscolhido == null) {
			response.sendRedirect("agendamento?erro=dados_incompletos");
			return;
		}

		try {
			int idMedico = Integer.parseInt(idMedicoStr);
			
			// Chama o DAO para gravar no MySQL
			boolean sucesso = com.example.main.dao.ConsultaDAO.agendarNovaConsulta(usuarioLogado.getIdPerfil(), idMedico, dataEscolhida, horarioEscolhido);
			
			if (sucesso) {
				// Se salvou, redireciona para a Home real!
				response.sendRedirect(request.getContextPath() + "/home");
			} else {
				response.sendRedirect("agendamento?erro=banco");
			}
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("agendamento?erro=sistema");
		}
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String acao = request.getParameter("acao");
		
		// Se não tiver ação, carrega a página HTML inteira
		if (acao == null) {
			carregarPaginaAgendamento(request, response);
			return;
		}
		
		// Se tiver ação, responde apenas os fragmentos para o JavaScript (AJAX)
		switch (acao) {
			case "buscarMedicos":
				buscarMedicosAjax(request, response);
				break;
			case "buscarDatas":
				buscarDatasAjax(request, response);
				break;
			case "buscarHorarios":
				buscarHorariosAjax(request, response);
				break;
			default:
				carregarPaginaAgendamento(request, response);
				break;
		}
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
	
	// --- MÉTODOS PARA RESPONDER AO JAVASCRIPT ---
	
	private void buscarMedicosAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.setContentType("text/html;charset=UTF-8");
		PrintWriter out = response.getWriter();
		String idEspecialidade = request.getParameter("id_especialidade");
		
		try {
			// AQUI precisaremos chamar um método do PerfilDAO/UsuarioDAO para buscar 
			// os perfis de médicos que tenham essa especialidade.
			// Por enquanto, coloquei um HTML fixo só para não quebrar a tela:
			out.println("<option value='' disabled selected>Selecione um médico</option>");
			out.println("<option value='3'>Dr. Fernando (ID: 3)</option>"); 
		} catch (Exception e) {
			out.println("<option value=''>Erro ao buscar médicos</option>");
		}
	}
	
	private void buscarDatasAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.setContentType("application/json;charset=UTF-8");
		PrintWriter out = response.getWriter();
		String idMedico = request.getParameter("id_medico");
		
		try {
			// AQUI precisaremos consultar a tabela agenda_medico e devolver o array JSON.
			// Fixo para teste do layout:
			out.print("[\"2026-05-15\", \"2026-05-20\"]");
		} catch (Exception e) {
			out.print("[]");
		}
	}
	
	private void buscarHorariosAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.setContentType("text/html;charset=UTF-8");
		PrintWriter out = response.getWriter();
		String data = request.getParameter("data");
		
		try {
			// AQUI vamos consultar a tabela agenda_medico, cruzar com a tabela consultas 
			// e gerar os botões (slot-btn) de 30 em 30 min.
			// Fixo para teste do layout:
			out.println("<div class='slot-btn' onclick=\"selecionarHorario(this, '08:00')\">08:00</div>");
			out.println("<div class='slot-btn' onclick=\"selecionarHorario(this, '08:30')\">08:30</div>");
		} catch (Exception e) {
			out.println("<p>Erro ao buscar horários.</p>");
		}
	}
}