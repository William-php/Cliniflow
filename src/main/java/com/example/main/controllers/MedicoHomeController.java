package com.example.main.controllers;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import com.example.main.dao.MedicoDashboardDAO;
import com.example.main.models.Perfil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "medicoHome", urlPatterns = {"/medico-home"})
public class MedicoHomeController extends HttpServlet {

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

            Object[] proxConsulta = MedicoDashboardDAO.getProximaConsulta(idMedico);
            if (proxConsulta != null) {
                request.setAttribute("proxPaciente", (String) proxConsulta[0]);
                LocalDateTime dataHora = (LocalDateTime) proxConsulta[1];
                DateTimeFormatter formatador = DateTimeFormatter.ofPattern("dd/MM/yyyy 'às' HH:mm");
                request.setAttribute("proxHorario", dataHora.format(formatador));
            } else {
                request.setAttribute("proxPaciente", "Nenhum paciente agendado");
                request.setAttribute("proxHorario", "--");
            }

            request.setAttribute("consultasDia", MedicoDashboardDAO.getContagemConsultas(idMedico, "DIA"));
            request.setAttribute("consultasMes", MedicoDashboardDAO.getContagemConsultas(idMedico, "MES"));
            request.setAttribute("concluidasMes", MedicoDashboardDAO.getContagemConsultas(idMedico, "CONCLUIDAS"));

            request.setAttribute("datasComAgenda", MedicoDashboardDAO.getDatasComAgendaJSON(idMedico));
            request.setAttribute("dadosGraficoAno", MedicoDashboardDAO.getDadosGraficoAnualJSON(idMedico));

            request.getRequestDispatcher("medico-home.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?erro=sistema");
        }
    }
}