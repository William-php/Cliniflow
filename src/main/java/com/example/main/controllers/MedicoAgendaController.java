package com.example.main.controllers;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList; // ISSO AQUI RESOLVE O "X" VERMELHO!
import java.util.List;
import java.util.Map;

import com.example.main.dao.ConsultaDAO;
import com.example.main.dao.MedicoAgendaDAO;
import com.example.main.models.Perfil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "medicoAgenda", urlPatterns = {"/medico-agenda"})
public class MedicoAgendaController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");

        if (usuarioLogado == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        try {
            int idMedico = usuarioLogado.getIdPerfil();
            
            LocalDate dataSelecionada = LocalDate.now();
            String paramData = request.getParameter("data");
            if (paramData != null && !paramData.isEmpty()) {
                dataSelecionada = LocalDate.parse(paramData);
            }

            int mes = dataSelecionada.getMonthValue();
            int ano = dataSelecionada.getYear();

            int totalDiasNoMes = dataSelecionada.lengthOfMonth();
            List<LocalDate> todosOsDiasDoMes = new ArrayList<>();
            for (int d = 1; d <= totalDiasNoMes; d++) {
                todosOsDiasDoMes.add(LocalDate.of(ano, mes, d));
            }

            // busca quais desses dias tem consultas
            List<LocalDate> diasComConsulta = MedicoAgendaDAO.getDiasComConsultaNoMes(idMedico, mes, ano);

            List<Map<String, Object>> consultasDoDia = MedicoAgendaDAO.getConsultasDoDia(idMedico, dataSelecionada);

            request.setAttribute("todosOsDiasDoMes", todosOsDiasDoMes);
            request.setAttribute("diasComConsulta", diasComConsulta);
            request.setAttribute("dataSelecionada", dataSelecionada);
            request.setAttribute("consultasDoDia", consultasDoDia);
            
            request.getRequestDispatcher("medico-agenda.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("medico-home?erro=sistema");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String acao = request.getParameter("acao");
        String dataRetorno = request.getParameter("data_atual"); 
        
        try {
            int idConsulta = Integer.parseInt(request.getParameter("id_consulta"));

            if ("atender".equals(acao)) {
                ConsultaDAO.atualizarStatusConsulta(idConsulta, "Concluida"); 
            } else if ("faltou".equals(acao)) {
                ConsultaDAO.atualizarStatusConsulta(idConsulta, "Cancelada"); 
            }
            
            response.sendRedirect("medico-agenda?data=" + dataRetorno + "&sucesso=atualizado");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("medico-agenda?data=" + dataRetorno + "&erro=falha");
        }
    }
}