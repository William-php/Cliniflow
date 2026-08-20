package com.example.main.controllers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import com.example.main.dao.EspecialidadeDAO;
import com.example.main.dao.ListaEsperaDAO;
import com.example.main.models.Especialidade;
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
				List<Map<String, Object>> filasDetalhadas = ListaEsperaDAO.getDetalhesFilaPaciente(idPerfil);
				request.setAttribute("filasDetalhadas", filasDetalhadas);
				
                HashMap<Integer, String> mapaEspecialidades = new HashMap<>();
                HashSet<Especialidade> todasEsp = EspecialidadeDAO.getEspecialidades();
                
                for (Map<String, Object> fila : filasDetalhadas) {
                    if (fila.get("idMedico") != null) {
                        int idMedico = (Integer) fila.get("idMedico");
                        
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
                request.setAttribute("mapaEspecialidades", mapaEspecialidades);
				
				request.getRequestDispatcher("lista-espera.jsp").forward(request, response);
			} catch (Exception e) {
				e.printStackTrace();
			}
		} else {
			response.sendRedirect("index.jsp");
		}
	}
}