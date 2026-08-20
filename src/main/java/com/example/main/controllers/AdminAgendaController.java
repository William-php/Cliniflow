package com.example.main.controllers;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import com.example.main.dao.AgendaDAO;
import com.example.main.dao.EspecialidadeDAO;
import com.example.main.models.AgendaMedico;
import com.example.main.models.Especialidade;
import com.example.main.models.Perfil;
import com.example.main.utils.Conexao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "adminAgendas", urlPatterns = {"/admin-agendas"})
public class AdminAgendaController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
        
        if (usuarioLogado != null && usuarioLogado.getUsuario() != null && usuarioLogado.getUsuario().isAdmUsuario()) {
            try {
                HashSet<AgendaMedico> listaAgendas = AgendaDAO.getTodasAgendas();
                request.setAttribute("listaAgendas", listaAgendas);
                
                // carrega todos os medicos e especialidades para o modal
                List<Perfil> listaMedicos = new ArrayList<>();
                try (java.sql.Connection conn = Conexao.conectar();
                     java.sql.PreparedStatement stmt = conn.prepareStatement(
                         "SELECT p.id_perfil, u.nome_usuario, u.sobrenome_usuario " +
                         "FROM perfis p JOIN usuarios u ON p.usuario = u.id_usuario WHERE p.tipo_perfil = 'MEDICO'")) {
                    java.sql.ResultSet rs = stmt.executeQuery();
                    while (rs.next()) {
                        Perfil p = new Perfil();
                        p.setIdPerfil(rs.getInt("id_perfil"));
                        com.example.main.models.Usuario u = new com.example.main.models.Usuario();
                        u.setNomeUsuario(rs.getString("nome_usuario"));
                        u.setSobrenomeUsuario(rs.getString("sobrenome_usuario"));
                        p.setUsuario(u);
                        listaMedicos.add(p);
                    }
                }
                
                request.setAttribute("listaMedicos", listaMedicos);
                request.setAttribute("todasEspecialidades", EspecialidadeDAO.getEspecialidades());
                
                request.getRequestDispatcher("admin-agendas.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("admin-home");
            }
        } else {
            response.sendRedirect("index.jsp");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String acao = request.getParameter("acao");
        
        if ("nova_agenda".equals(acao)) {
            try {
                int idMedico = Integer.parseInt(request.getParameter("medico"));
                int idEspecialidade = Integer.parseInt(request.getParameter("especialidade"));
                LocalDate data = LocalDate.parse(request.getParameter("data_agenda"));
                LocalTime inicio = LocalTime.parse(request.getParameter("hora_inicio"));
                LocalTime fim = LocalTime.parse(request.getParameter("hora_fim"));
                
                AgendaMedico nova = new AgendaMedico();
                Perfil p = new Perfil();
                p.setIdPerfil(idMedico);
                nova.setMedico(p);
                
                Especialidade esp = new Especialidade();
                esp.setIdEspecialidade(idEspecialidade);
                nova.setEspecialidade(esp);
                
                nova.setDataAgenda(data);
                nova.setHoraInicio(inicio);
                nova.setHoraFim(fim);
                
                AgendaDAO.inserirAgenda(nova);
                
                response.sendRedirect("admin-agendas?sucesso=criada");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("admin-agendas?erro=falha");
            }
        }
    }
}