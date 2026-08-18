package com.example.main.controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashSet;
import java.util.List;

import com.example.main.dao.AgendamentoDAO;
import com.example.main.dao.EspecialidadeDAO;
import com.example.main.models.AgendaMedico;
import com.example.main.models.Especialidade;
import com.example.main.models.Perfil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "agendamento", urlPatterns = "/agendamento")
public class AgendamentoController extends HttpServlet {
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");

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
            LocalDate data = LocalDate.parse(dataEscolhida);
            
            String[] partesHorario = horarioEscolhido.split("\\|");
            LocalTime horario = LocalTime.parse(partesHorario[0]);
            String situacao = partesHorario[1];
            java.time.LocalDateTime dataHoraInicio = java.time.LocalDateTime.of(data, horario);

            if ("LIVRE".equals(situacao)) {
                com.example.main.dao.ConsultaDAO.agendarNovaConsulta(usuarioLogado.getIdPerfil(), idMedico, dataEscolhida, partesHorario[0]);
                response.sendRedirect(request.getContextPath() + "/home?sucesso=agendada");
            } else {
                int idConsultaOcupada = Integer.parseInt(situacao);
                com.example.main.dao.ListaEsperaDAO.entrarListaEspera(usuarioLogado.getIdPerfil(), idConsultaOcupada);
                
                response.sendRedirect(request.getContextPath() + "/minha-lista-espera?sucesso=espera");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("agendamento?erro=sistema");
        }
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String acao = request.getParameter("acao");
		
		if (acao == null) {
			carregarPaginaAgendamento(request, response);
			return;
		}
		
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
			request.setAttribute("especialidades", especialidades);
			request.getRequestDispatcher("agendamento.jsp").forward(request, response);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private void buscarMedicosAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.setContentType("text/html;charset=UTF-8");
		PrintWriter out = response.getWriter();
		
		try {
			int idEspecialidade = Integer.parseInt(request.getParameter("id_especialidade"));
			List<Perfil> medicos = AgendamentoDAO.getMedicosDisponiveisPorEspecialidade(idEspecialidade);
			
			if (medicos.isEmpty()) {
				out.println("<option value='' disabled selected>Nenhum médico com agenda para esta especialidade</option>");
			} else {
				out.println("<option value='' disabled selected>Selecione um médico...</option>");
				for (Perfil m : medicos) {
					out.println("<option value='" + m.getIdPerfil() + "'>Dr(a). " + 
								m.getUsuario().getNomeUsuario() + " " + m.getUsuario().getSobrenomeUsuario() + "</option>");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			out.println("<option value=''>Erro ao buscar médicos</option>");
		}
	}
	
	private void buscarDatasAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.setContentType("application/json;charset=UTF-8");
		PrintWriter out = response.getWriter();
		
		try {
			int idMedico = Integer.parseInt(request.getParameter("id_medico"));
			List<String> datas = AgendamentoDAO.getDatasDisponiveisMedico(idMedico);
			
			StringBuilder json = new StringBuilder("[");
			for (int i = 0; i < datas.size(); i++) {
				String dataStr = datas.get(i);
				LocalDate data = LocalDate.parse(dataStr);
				
				List<AgendaMedico> turnos = AgendamentoDAO.getTurnosDoDia(idMedico, data);
				int totalSlots = 0;
				int slotsOcupados = 0;
				
				for (AgendaMedico turno : turnos) {
					LocalTime t = turno.getHoraInicio();
					LocalTime fim = turno.getHoraFim();
					while (t.isBefore(fim)) {
						totalSlots++;
						LocalDateTime dataHora = LocalDateTime.of(data, t);
						if (AgendamentoDAO.getConsultaExistente(idMedico, dataHora) != null) {
							slotsOcupados++;
						}
						t = t.plusMinutes(30);
					}
				}
				
				boolean lotado = (totalSlots > 0 && slotsOcupados >= totalSlots);
				
				json.append("{\"data\":\"").append(dataStr).append("\",\"lotado\":").append(lotado).append("}");
				if (i < datas.size() - 1) json.append(",");
			}
			json.append("]");
			
			out.print(json.toString());
		} catch (Exception e) {
			e.printStackTrace();
			out.print("[]");
		}
	}
	
	private void buscarHorariosAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.setContentType("text/html;charset=UTF-8");
		PrintWriter out = response.getWriter();
		
		try {
			int idMedico = Integer.parseInt(request.getParameter("id_medico"));
			LocalDate data = LocalDate.parse(request.getParameter("data"));
			
			List<AgendaMedico> turnos = AgendamentoDAO.getTurnosDoDia(idMedico, data);
			
			if (turnos.isEmpty()) {
				out.println("<p style='color: #718096; font-size: 14px; grid-column: 1/-1;'>Nenhum horário disponível nesta data.</p>");
				return;
			}
			
			for (AgendaMedico turno : turnos) {
				LocalTime tempoAtual = turno.getHoraInicio();
				LocalTime tempoFim = turno.getHoraFim();
				
				while (tempoAtual.isBefore(tempoFim)) {
					LocalDateTime dataHoraSlot = LocalDateTime.of(data, tempoAtual);
					Integer idConsultaExistente = AgendamentoDAO.getConsultaExistente(idMedico, dataHoraSlot);
					
					if (idConsultaExistente != null) {
						out.println("<div class='slot-btn occupied' onclick=\"selecionarHorario(this, '" + tempoAtual + "|" + idConsultaExistente + "')\">" + 
									tempoAtual + "</div>");
					} else {
						out.println("<div class='slot-btn' onclick=\"selecionarHorario(this, '" + tempoAtual + "|LIVRE')\">" + 
									tempoAtual + "</div>");
					}
					tempoAtual = tempoAtual.plusMinutes(30);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			out.println("<p style='color: #E53E3E;'>Erro ao processar horários.</p>");
		}
	}
}