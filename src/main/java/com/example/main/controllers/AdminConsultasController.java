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

@WebServlet(name = "adminConsultas", urlPatterns = {"/admin-consultas"})
public class AdminConsultasController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Perfil adminLogado = (Perfil) session.getAttribute("usuarioLogado");
        
        if (adminLogado != null && adminLogado.getUsuario() != null && adminLogado.getUsuario().isAdmUsuario()) {
            try {
                HashSet<Consulta> listaConsultas = ConsultaDAO.getTodasConsultasAdmin();
                request.setAttribute("listaConsultas", listaConsultas);
                
                // busca especialidades dos medicos e cria um mapa
                HashMap<Integer, String> mapaEspecialidades = new HashMap<>();
                HashSet<Especialidade> todasEsp = EspecialidadeDAO.getEspecialidades();
                
                for (Consulta c : listaConsultas) {
                    if (c.getMedicoConsulta() != null) {
                        int idMedico = c.getMedicoConsulta().getIdPerfil();
                        
                        if (!mapaEspecialidades.containsKey(idMedico)) {
                            List<Integer> idsEsp = EspecialidadeDAO.getIdsEspecialidadesDoMedico(idMedico);
                            List<String> nomesEsp = new ArrayList<>();
                            
                            for (Integer id : idsEsp) {
                                for (Especialidade e : todasEsp) {
                                    if (e.getIdEspecialidade() == id) {
                                        nomesEsp.add(e.getTipoEspecialidade().name()); // Pega o TIPO (ex: ORTOPEDIA)
                                    }
                                }
                            }
                            
                            String textoEsp = nomesEsp.isEmpty() ? "Clínico Geral" : String.join(", ", nomesEsp);
                            mapaEspecialidades.put(idMedico, textoEsp);
                        }
                    }
                }
                
                request.setAttribute("mapaEspecialidades", mapaEspecialidades);
                
                request.getRequestDispatcher("admin-consultas.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("admin-home?erro=banco");
            }
        } else {
            response.sendRedirect("index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String acao = request.getParameter("acao");
        
        try {
            if ("cancelar".equals(acao)) {
                int idConsulta = Integer.parseInt(request.getParameter("id_consulta"));
                ConsultaDAO.atualizarStatusConsulta(idConsulta, "Cancelada");
                response.sendRedirect("admin-consultas?sucesso=cancelada");
            } else if ("concluir".equals(acao)) {
                int idConsulta = Integer.parseInt(request.getParameter("id_consulta"));
                ConsultaDAO.atualizarStatusConsulta(idConsulta, "Concluida");
                response.sendRedirect("admin-consultas?sucesso=concluida");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-consultas?erro=falha");
        }
    }
}