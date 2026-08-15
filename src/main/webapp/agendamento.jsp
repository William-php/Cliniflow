<%@page import="java.util.HashSet"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.Collection, com.example.main.models.Perfil, com.example.main.models.Especialidade" %>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.html");
        return;
    }
    String nomeUsuario = usuarioLogado.getUsuario() != null ? usuarioLogado.getUsuario().getNomeUsuario() : "Usuário";
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Novo Agendamento</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Estilos específicos complementares para a tela de agendamento baseados no seu print */
        .agendamento-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; margin-top: 24px; }
        .select-custom { width: 100%; padding: 14px; border: 1px solid #E2E8F0; border-radius: 8px; font-size: 16px; color: #2D3748; background-color: #FFF; margin-bottom: 20px; box-sizing: border-box; }
        .calendar-box { text-align: center; }
        .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 8px; text-align: center; margin-top: 12px; }
        .calendar-header { font-weight: bold; color: #A0AEC0; font-size: 14px; padding-bottom: 8px; }
        .calendar-day { padding: 10px; font-size: 14px; color: #4A5568; cursor: pointer; border-radius: 50%; }
        .calendar-day:hover { background-color: #E6FFFA; color: #12A388; }
        .calendar-day.selected { background-color: #E6FFFA; color: #12A388; border: 2px solid #12A388; font-weight: bold; }
        .calendar-day.muted { color: #CBD5E0; }
        
        .slots-container { display: flex; flex-direction: column; justify-content: space-between; height: 100%; }
        .slots-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 24px; }
        .slot-btn { background-color: #FFF; border: 1px solid #319795; color: #319795; padding: 12px; border-radius: 8px; font-weight: bold; cursor: pointer; text-align: center; transition: all 0.2s; }
        .slot-btn:hover, .slot-btn.active { background-color: #E6FFFA; border-color: #12A388; color: #12A388; }
        .btn-confirmar-agendamento { background-color: #A0AEC0; color: white; border: none; width: 100%; padding: 14px; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <!-- BARRA LATERAL -->
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="consultas" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
            <a href="agendamento" class="nav-item"><i class="fa-solid fa-notes-medical"></i> Consultas</a>
            <a href="#" class="nav-item"><i class="fa-solid fa-user"></i> Perfil</a>
            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
        </ul>
        <a href="index.html" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;"><i class="fa-solid fa-arrow-right-from-bracket"></i> Sair</a>
    </aside>

    <!-- ÁREA PRINCIPAL -->
    <main class="main-content">
        
        <header class="topbar">
            <div class="topbar-user">
                <p>Novo Agendamento,</p>
                <h3><%= nomeUsuario %></h3>
            </div>
        </header>

        <div class="content-area" style="grid-template-columns: 1fr; padding-top: 32px;">
            <div class="content-card">
                <h3 class="section-title" style="font-size: 20px; margin-bottom: 24px;">Agendar Consulta</h3>

                <form action="agendamento" method="POST">
                    <!-- Seleção de Especialidade -->
                    <div class="input-group" style="margin-bottom: 0;">
                        <label style="font-size: 12px; color: #A0AEC0; margin-bottom: 4px; display: block;">Especialidade</label>
                        <select name="id_especialidade" class="select-custom" required>
                            <option value="" disabled selected>Selecione uma especialidade</option>
                            <%
                                @SuppressWarnings("unchecked")
                                HashSet<Especialidade> listaEspecialidades = (HashSet<Especialidade>) request.getAttribute("especialidades");
                                if (listaEspecialidades != null) {
                                    for (Especialidade esp : listaEspecialidades) {
                            %>
                                    <option value="<%= esp.getIdEspecialidade() %>"><%= esp.getTipoEspecialidade().name() %></option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>

                    <!-- Seleção de Médico (Futuramente populado via JS/Controller dependendo da especialidade) -->
                    <div class="input-group" style="margin-bottom: 0;">
                        <label style="font-size: 12px; color: #A0AEC0; margin-bottom: 4px; display: block;">Médico</label>
                        <select name="id_medico" class="select-custom" required>
                            <option value="" disabled selected>Selecione primeiro a especialidade</option>
                        </select>
                    </div>

                    <!-- Grid do Calendário e Horários conforme seu protótipo -->
                    <div class="agendamento-grid">
                        
                        <!-- Mini Calendário Estático/Visual (Maio 2026) -->
                        <div class="calendar-box">
                            <h4 style="color: #2D3748; font-weight: bold; margin-bottom: 12px;">Maio 2026</h4>
                            <div class="calendar-grid">
                                <div class="calendar-header">D</div>
                                <div class="calendar-header">S</div>
                                <div class="calendar-header">T</div>
                                <div class="calendar-header">Q</div>
                                <div class="calendar-header">Q</div>
                                <div class="calendar-header">S</div>
                                <div class="calendar-header">S</div>
                                
                                <div class="calendar-day muted">26</div>
                                <div class="calendar-day muted">27</div>
                                <div class="calendar-day muted">28</div>
                                <div class="calendar-day muted">29</div>
                                <div class="calendar-day muted">30</div>
                                <div class="calendar-day">1</div>
                                <div class="calendar-day">2</div>
                                
                                <div class="calendar-day">3</div>
                                <div class="calendar-day">4</div>
                                <div class="calendar-day">5</div>
                                <div class="calendar-day">6</div>
                                <div class="calendar-day">7</div>
                                <div class="calendar-day">8</div>
                                <div class="calendar-day">9</div>
                                
                                <div class="calendar-day">10</div>
                                <div class="calendar-day">11</div>
                                <div class="calendar-day">12</div>
                                <div class="calendar-day">13</div>
                                <div class="calendar-day">14</div>
                                <div class="calendar-day selected">15</div>
                                <div class="calendar-day">16</div>
                                
                                <div class="calendar-day">17</div>
                                <div class="calendar-day">18</div>
                                <div class="calendar-day">19</div>
                                <div class="calendar-day">20</div>
                                <div class="calendar-day">21</div>
                                <div class="calendar-day">22</div>
                                <div class="calendar-day">23</div>
                                
                                <div class="calendar-day">24</div>
                                <div class="calendar-day">25</div>
                                <div class="calendar-day">26</div>
                                <div class="calendar-day">27</div>
                                <div class="calendar-day">28</div>
                                <div class="calendar-day">29</div>
                                <div class="calendar-day">30</div>
                                
                                <div class="calendar-day muted">31</div>
                            </div>
                        </div>

                        <!-- Horários Disponíveis -->
                        <div class="slots-container">
                            <div>
                                <h4 style="color: #2D3748; font-weight: bold; margin-bottom: 16px;">Horários — Dia 15</h4>
                                <div class="slots-grid">
                                    <div class="slot-btn">08:00</div>
                                    <div class="slot-btn">08:30</div>
                                    <div class="slot-btn">09:00</div>
                                    <div class="slot-btn active">09:30</div>
                                    <div class="slot-btn">10:00</div>
                                    <div class="slot-btn">10:30</div>
                                    <div class="slot-btn">11:00</div>
                                    <div class="slot-btn">11:30</div>
                                </div>
                            </div>
                            
                            <button type="submit" class="btn-main" style="margin-bottom: 0;">Agendar</button>
                        </div>

                    </div>
                </form>

            </div>
        </div>
    </main>
</div>

</body>
</html>