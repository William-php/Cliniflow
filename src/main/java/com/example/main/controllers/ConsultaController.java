package com.example.main.controllers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

import com.example.main.dao.ConsultaDAO;
import com.example.main.dao.EspecialidadeDAO;
import com.example.main.models.Consulta;
import com.example.main.models.Especialidade;
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
		
		if ("cancelar".equals(acao)) {
			try {
				int idConsulta = Integer.parseInt(request.getParameter("id_consulta"));
				
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
				consultasPorUsuarioLogado = ConsultaDAO.getConsultaByPacienteId(usuarioLogado.getIdPerfil());				
				request.setAttribute("consultasUsuarioLogado", consultasPorUsuarioLogado);
				
				Consulta proximaConsulta = ConsultaDAO.getProximaConsultaByPacienteId(usuarioLogado.getIdPerfil());
				if (proximaConsulta != null && proximaConsulta.getMedicoConsulta() != null) {
					String nomeMedico = "Dr(a). " + proximaConsulta.getMedicoConsulta().getUsuario().getNomeUsuario();
					String dataFormatada = proximaConsulta.getDataHoraInicioConsulta().toString().replace("T", " às ");
					request.setAttribute("proxMedico", nomeMedico);
					request.setAttribute("proxData", dataFormatada);
				}
				
				request.setAttribute("consultasDia", ConsultaDAO.countConsultasByFiltro(usuarioLogado.getIdPerfil(), "DIA"));
				request.setAttribute("consultasMes", ConsultaDAO.countConsultasByFiltro(usuarioLogado.getIdPerfil(), "MES"));
				request.setAttribute("totalConsultas", ConsultaDAO.countConsultasByFiltro(usuarioLogado.getIdPerfil(), "TOTAL"));
				
				request.getRequestDispatcher("home.jsp").forward(request, response);
			} catch (Exception e) {
				e.printStackTrace();
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
		HashMap<Integer, String> mapaEspecialidades = new HashMap<>();
		
		if (usuarioLogado != null) {
			try {					
				consultasPorUsuarioLogado = ConsultaDAO.getConsultaByPacienteId(usuarioLogado.getIdPerfil());
				HashSet<Especialidade> todasEsp = EspecialidadeDAO.getEspecialidades();
				if (todasEsp.size() > 0) {
					for (Consulta c : consultasPorUsuarioLogado) {
                        if (c.getMedicoConsulta() != null) {
                            int idMedico = c.getMedicoConsulta().getIdPerfil();
                            
                            if (!mapaEspecialidades.containsKey(idMedico)) {
                                List<Integer> idsEsp = EspecialidadeDAO.getIdsEspecialidadesDoMedico(idMedico);
                                List<String> nomesEsp = new ArrayList<>();
                                
                                for (Integer id : idsEsp) {
                                    for (Especialidade e : todasEsp) {
                                        if (e.getIdEspecialidade() == id) {
                                            nomesEsp.add(e.getTipoEspecialidade().name());
                                        }
                                    }
                                }
                                
                                String textoEsp = nomesEsp.isEmpty() ? "Clínico Geral" : String.join(", ", nomesEsp);
                                mapaEspecialidades.put(idMedico, textoEsp);
                            }
                        }
                    }
				}
				request.setAttribute("mapaEspecialidades", mapaEspecialidades);
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