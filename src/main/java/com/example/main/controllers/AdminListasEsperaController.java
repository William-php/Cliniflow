package com.example.main.controllers;

import java.io.IOException;
import java.io.PrintWriter;
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

@WebServlet(name = "adminListasEspera", urlPatterns = {"/admin-listas-espera"})
public class AdminListasEsperaController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Perfil adminLogado = (Perfil) session.getAttribute("usuarioLogado");
        
        if (adminLogado == null || adminLogado.getUsuario() == null || !adminLogado.getUsuario().isAdmUsuario()) {
            response.sendRedirect("index.jsp");
            return;
        }

        String acao = request.getParameter("acao");
        
        try {
            if ("buscar_pacientes".equals(acao)) {
                int idConsulta = Integer.parseInt(request.getParameter("id_consulta"));
                List<Map<String, Object>> pacientes = ListaEsperaDAO.getPacientesFilaAdmin(idConsulta);
                
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                
                if (pacientes.isEmpty()) {
                    out.println("<p style='text-align:center; color:#A0AEC0; padding: 24px;'>Nenhum paciente nesta fila.</p>");
                } else {
                    for (Map<String, Object> p : pacientes) {
                        int idLista = (Integer) p.get("idListaEspera");
                        int pos = (Integer) p.get("posicao");
                        int idPac = (Integer) p.get("idPaciente");
                        String nomePac = (String) p.get("nomePaciente");
                        
                        // HTML do paciente com o Botão de Alocar Vaga e Remover
                        out.println("<div class='fila-patient-item'>");
                        out.println("   <div class='fpi-info'>");
                        out.println("       <span class='fpi-pos'>" + pos + "º</span>");
                        out.println("       <span class='fpi-name'>" + nomePac + "</span>");
                        out.println("   </div>");
                        out.println("   <div class='fpi-actions'>");
                        out.println("       <form action='admin-listas-espera' method='POST' onsubmit=\"return confirm('Deseja ALOCAR A VAGA para este paciente? Ele se tornará o titular da consulta.');\">");
                        out.println("           <input type='hidden' name='acao' value='alocar_vaga'>");
                        out.println("           <input type='hidden' name='id_consulta' value='" + idConsulta + "'>");
                        out.println("           <input type='hidden' name='id_paciente' value='" + idPac + "'>");
                        out.println("           <input type='hidden' name='id_lista_espera' value='" + idLista + "'>");
                        out.println("           <input type='hidden' name='posicao' value='" + pos + "'>");
                        out.println("           <button type='submit' class='btn-alocar'>Alocar Vaga</button>");
                        out.println("       </form>");
                        out.println("       <form action='admin-listas-espera' method='POST' onsubmit=\"return confirm('Remover este paciente da fila?');\">");
                        out.println("           <input type='hidden' name='acao' value='remover_paciente'>");
                        out.println("           <input type='hidden' name='id_consulta' value='" + idConsulta + "'>");
                        out.println("           <input type='hidden' name='id_lista_espera' value='" + idLista + "'>");
                        out.println("           <input type='hidden' name='posicao' value='" + pos + "'>");
                        out.println("           <button type='submit' class='btn-remover' title='Remover da Fila'><i class='fa-solid fa-trash'></i></button>");
                        out.println("       </form>");
                        out.println("   </div>");
                        out.println("</div>");
                    }
                }
                return;
            }

            List<Map<String, Object>> filas = ListaEsperaDAO.getFilasAtivasAdmin();
            request.setAttribute("filas", filas);
            
            // mapeia especialidade do medicos
            HashMap<Integer, String> mapaEspecialidades = new HashMap<>();
            HashSet<Especialidade> todasEsp = EspecialidadeDAO.getEspecialidades();
            
            for (Map<String, Object> fila : filas) {
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
            request.setAttribute("mapaEspecialidades", mapaEspecialidades);
            
            request.getRequestDispatcher("admin-listas-espera.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-home?erro=sistema");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String acao = request.getParameter("acao");
        
        try {
            if ("encerrar_fila".equals(acao)) {
                int idConsulta = Integer.parseInt(request.getParameter("id_consulta"));
                ListaEsperaDAO.encerrarFilaCompleta(idConsulta);
                response.sendRedirect("admin-listas-espera?sucesso=encerrada");
                
            } else if ("remover_paciente".equals(acao)) {
                int idLista = Integer.parseInt(request.getParameter("id_lista_espera"));
                int idConsulta = Integer.parseInt(request.getParameter("id_consulta"));
                int pos = Integer.parseInt(request.getParameter("posicao"));
                ListaEsperaDAO.removerPacienteReordenar(idLista, idConsulta, pos);
                response.sendRedirect("admin-listas-espera?sucesso=removido");
                
            } else if ("alocar_vaga".equals(acao)) {
                int idConsulta = Integer.parseInt(request.getParameter("id_consulta"));
                int idPaciente = Integer.parseInt(request.getParameter("id_paciente"));
                int idLista = Integer.parseInt(request.getParameter("id_lista_espera"));
                int pos = Integer.parseInt(request.getParameter("posicao"));
                ListaEsperaDAO.alocarVagaParaPaciente(idConsulta, idPaciente, idLista, pos);
                response.sendRedirect("admin-listas-espera?sucesso=alocada");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-listas-espera?erro=falha");
        }
    }
}