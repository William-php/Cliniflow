<%@page import="com.example.main.models.Perfil"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Locale"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String nomeMedico = usuarioLogado.getUsuario() != null ? usuarioLogado.getUsuario().getNomeUsuario() + " " + usuarioLogado.getUsuario().getSobrenomeUsuario() : "Médico";
    
    // VARIÁVEIS CORRIGIDAS
    @SuppressWarnings("unchecked")
    List<LocalDate> diasComConsulta = (List<LocalDate>) request.getAttribute("diasComConsulta");
    LocalDate dataSelecionada = (LocalDate) request.getAttribute("dataSelecionada");
    
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> consultas = (List<Map<String, Object>>) request.getAttribute("consultasDoDia");
    
    DateTimeFormatter formataDia = DateTimeFormatter.ofPattern("dd");
    DateTimeFormatter formataSemana = DateTimeFormatter.ofPattern("EEE", new Locale("pt", "BR"));
    DateTimeFormatter formataHora = DateTimeFormatter.ofPattern("HH:mm");
    DateTimeFormatter formataTitulo = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Minha Agenda</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body.home-body, .dashboard-layout { height: 100vh; overflow: hidden; margin: 0; }
        .main-content { display: flex; flex-direction: column; height: 100vh; overflow: hidden; background-color: #F7FAFC; position: relative; }
        .topbar-admin { background-color: #12A388; padding: 24px 40px; color: #FFFFFF; flex-shrink: 0; display: flex; justify-content: space-between; align-items: center; }
        .topbar-admin h2 { font-size: 22px; margin: 0; font-weight: 700; display: flex; align-items: center; gap: 12px; }
        .btn-voltar { color: #FFFFFF; text-decoration: none; font-size: 20px; transition: 0.2s; }
        .btn-voltar:hover { opacity: 0.8; transform: translateX(-4px); }

        .scroll-area { flex-grow: 1; overflow-y: auto; overflow-x: hidden; padding: 32px 40px; min-height: 0; }
        .scroll-area::-webkit-scrollbar { width: 6px; }
        .scroll-area::-webkit-scrollbar-thumb { background-color: #CBD5E0; border-radius: 4px; }
        .content-card-agenda { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 16px; padding: 32px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }

        /* CARROSSEL NOVO */
        .date-strip { display: flex; gap: 12px; overflow-x: auto; padding-bottom: 16px; margin-bottom: 24px; border-bottom: 1px solid #E2E8F0; }
        .date-strip::-webkit-scrollbar { height: 6px; }
        .date-strip::-webkit-scrollbar-thumb { background-color: #CBD5E0; border-radius: 4px; }
        
        .date-card { min-width: 64px; background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; padding: 10px 6px; text-align: center; cursor: pointer; transition: 0.2s; position: relative; }
        .date-card:hover { border-color: #12A388; }
        .date-card.active { background: #12A388; border-color: #12A388; box-shadow: 0 4px 10px rgba(18,163,136,0.2); }
        .date-card .weekday { display: block; font-size: 11px; margin-bottom: 2px; font-weight: 600; color: #A0AEC0; text-transform: uppercase; }
        .date-card.active .weekday { color: rgba(255,255,255,0.9); }
        .date-card .day { display: block; font-size: 18px; font-weight: 700; color: #2D3748; }
        .date-card.active .day { color: #FFFFFF; }

        /* TIMELINE E CARDS */
        .timeline-header { font-size: 18px; color: #4A5568; font-weight: bold; margin-bottom: 32px; }
        .timeline-container { max-width: 800px; margin: 0 auto; position: relative; padding-left: 20px; }
        .timeline-container::before { content: ''; position: absolute; top: 16px; bottom: 0; left: 88px; width: 2px; background-color: #E2E8F0; z-index: 1; }
        .timeline-row { display: flex; gap: 40px; margin-bottom: 24px; position: relative; z-index: 2; }
        .time-col { width: 48px; flex-shrink: 0; font-size: 16px; font-weight: 800; color: #2D3748; padding-top: 24px; text-align: right; background: #FFFFFF; }
        .card-col { flex-grow: 1; background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; padding: 20px 24px; display: flex; justify-content: space-between; align-items: center; transition: 0.2s; }
        
        .card-info h4 { margin: 0 0 4px 0; font-size: 18px; color: #2D3748; }
        .card-info p { margin: 0; font-size: 14px; color: #718096; }

        .card-agendada { border-left: 4px solid #3182CE; box-shadow: 0 4px 12px rgba(0,0,0,0.03); }
        .card-atendido { background-color: #F0FFF4; border-color: #C6F6D5; }
        .card-atendido .card-info h4, .card-atendido .card-info p { color: #22543D; opacity: 0.8; }
        .card-faltou { background-color: #FFF5F5; border-color: #FED7D7; }
        .card-faltou .card-info h4 { color: #C53030; }
        .card-faltou .card-info p { color: #E53E3E; opacity: 0.8; }
        .card-livre { background-color: #F7FAFC; border: 2px dashed #CBD5E0; }
        .card-livre .card-info h4 { color: #A0AEC0; font-weight: 600; }

        .card-actions { display: flex; gap: 12px; align-items: center; }
        .card-actions form { margin: 0; }
        .btn-acao { border: none; padding: 10px 16px; border-radius: 8px; font-size: 13px; font-weight: bold; cursor: pointer; transition: 0.2s; display: flex; align-items: center; gap: 8px; }
        .btn-acao.atender { background-color: #12A388; color: white; }
        .btn-acao.atender:hover { background-color: #0e826c; }
        .btn-acao.faltou { background-color: transparent; color: #E53E3E; border: 1px solid #FC8181; }
        .btn-acao.faltou:hover { background-color: #FFF5F5; }

        .status-badge { padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; display: flex; align-items: center; gap: 6px; }
        .badge-atendido { background-color: #C6F6D5; color: #22543D; }
        .badge-faltou { background-color: #FED7D7; color: #C53030; }
        .badge-livre { background-color: #E6FFFA; color: #12A388; }
        
        .toast-sucesso { position: fixed; top: 24px; right: 40px; background-color: #E6FFFA; color: #12A388; padding: 16px 24px; border-radius: 8px; border: 1px solid #12A388; font-size: 14px; font-weight: bold; box-shadow: 0 4px 12px rgba(0,0,0,0.1); display: flex; align-items: center; justify-content: space-between; gap: 24px; z-index: 9999; transition: opacity 0.3s ease; }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="medico-home" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
            <a href="medico-agenda" class="nav-item active"><i class="fa-solid fa-calendar-days"></i> Minha Agenda</a>
            <a href="editar-perfil" class="nav-item"><i class="fa-solid fa-user-doctor"></i> Perfil</a>
            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
        </ul>
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Tem certeza que deseja sair do sistema?');">
            <i class="fa-solid fa-arrow-right-from-bracket"></i> Sair
        </a>
    </aside>

    <main class="main-content">
        
        <% String sucesso = request.getParameter("sucesso"); if (sucesso != null) { %>
            <div id="toast-alerta" class="toast-sucesso">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <i class="fa-solid fa-circle-check"></i> 
                    <span>Status atualizado!</span>
                </div>
                <i class="fa-solid fa-xmark" style="cursor: pointer;" onclick="fecharToast()"></i>
            </div>
            <script>
                setTimeout(fecharToast, 4000);
                function fecharToast() {
                    var toast = document.getElementById("toast-alerta");
                    if(toast) { toast.style.opacity = "0"; setTimeout(() => toast.remove(), 300); }
                }
            </script>
        <% } %>

        <header class="topbar-admin">
            <h2>
                <a href="medico-home" class="btn-voltar"><i class="fa-solid fa-chevron-left"></i></a>
                Agenda de Atendimento
            </h2>
            <i class="fa-regular fa-calendar" style="font-size: 22px; cursor: pointer;"></i>
        </header>

        <div class="scroll-area">
            <div class="content-card-agenda">
                
                <!-- CARROSSEL ALIMENTADO APENAS COM DIAS COM CONSULTA -->
                <div class="date-strip">
                    <%
                        if (diasComConsulta != null && !diasComConsulta.isEmpty()) {
                            for (LocalDate d : diasComConsulta) {
                                boolean isAtivo = d.equals(dataSelecionada);
                                
                                String classeAtiva = isAtivo ? "active" : "";
                                String url = "medico-agenda?data=" + d.toString();
                    %>
                    <div class="date-card <%= classeAtiva %>" onclick="window.location.href='<%= url %>'">
                        <span class="weekday"><%= d.format(formataSemana).replace(".", "") %></span>
                        <span class="day"><%= d.format(formataDia) %></span>
                    </div>
                    <%
                            }
                        } else {
                    %>
                        <p style="color: #A0AEC0; padding: 12px;">Não há dias com consultas agendadas.</p>
                    <% } %>
                </div>

                <!-- TIMELINE DA DATA SELECIONADA -->
                <div class="timeline-container">
                    <% if (dataSelecionada != null) { %>
                        <div class="timeline-header">Programação para o dia <%= dataSelecionada.format(formataTitulo) %></div>
                    <% } %>

                    <%
                        if (consultas != null && !consultas.isEmpty()) {
                            for (Map<String, Object> c : consultas) {
                                int id = (Integer) c.get("idConsulta");
                                LocalDateTime dt = (LocalDateTime) c.get("dataHora");
                                String status = (String) c.get("status");
                                String nome = (String) c.get("nomePaciente");
                                String horario = dt != null ? dt.format(formataHora) : "--:--";

                                if ("LIVRE".equalsIgnoreCase(status) || nome == null) {
                    %>
                                    <div class="timeline-row">
                                        <div class="time-col"><%= horario %></div>
                                        <div class="card-col card-livre">
                                            <div class="card-info">
                                                <h4>Livre</h4>
                                            </div>
                                            <div class="card-actions">
                                                <span class="status-badge badge-livre">Disponível</span>
                                            </div>
                                        </div>
                                    </div>
                    <%
                                } else if ("AGENDADA".equalsIgnoreCase(status)) {
                    %>
                                    <div class="timeline-row">
                                        <div class="time-col"><%= horario %></div>
                                        <div class="card-col card-agendada">
                                            <div class="card-info">
                                                <h4><%= nome %></h4>
                                                <p>Consulta Padrão</p>
                                            </div>
                                            <div class="card-actions">
                                                <form action="medico-agenda" method="POST" onsubmit="return confirm('O paciente faltou à consulta?');">
                                                    <input type="hidden" name="acao" value="faltou">
                                                    <input type="hidden" name="id_consulta" value="<%= id %>">
                                                    <input type="hidden" name="data_atual" value="<%= dataSelecionada %>">
                                                    <button type="submit" class="btn-acao faltou"><i class="fa-solid fa-user-slash"></i> Faltou</button>
                                                </form>
                                                
                                                <form action="medico-agenda" method="POST" onsubmit="return confirm('Confirmar atendimento realizado?');">
                                                    <input type="hidden" name="acao" value="atender">
                                                    <input type="hidden" name="id_consulta" value="<%= id %>">
                                                    <input type="hidden" name="data_atual" value="<%= dataSelecionada %>">
                                                    <button type="submit" class="btn-acao atender"><i class="fa-solid fa-stethoscope"></i> Atender</button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                    <%
                                } else if ("CONCLUIDA".equalsIgnoreCase(status) || "REALIZADA".equalsIgnoreCase(status)) {
                    %>
                                    <div class="timeline-row">
                                        <div class="time-col"><%= horario %></div>
                                        <div class="card-col card-atendido">
                                            <div class="card-info">
                                                <h4><%= nome %></h4>
                                                <p>Consulta Padrão</p>
                                            </div>
                                            <div class="card-actions">
                                                <span class="status-badge badge-atendido"><i class="fa-solid fa-check-double"></i> Atendido</span>
                                            </div>
                                        </div>
                                    </div>
                    <%
                                } else if ("CANCELADA".equalsIgnoreCase(status)) {
                    %>
                                    <div class="timeline-row">
                                        <div class="time-col"><%= horario %></div>
                                        <div class="card-col card-faltou">
                                            <div class="card-info">
                                                <h4><%= nome %></h4>
                                                <p>Consulta Padrão</p>
                                            </div>
                                            <div class="card-actions">
                                                <span class="status-badge badge-faltou"><i class="fa-solid fa-xmark"></i> Faltou</span>
                                            </div>
                                        </div>
                                    </div>
                    <%
                                }
                            }
                        } else {
                    %>
                            <p style="color: #A0AEC0; text-align: center; margin-top: 40px;">
                                <i class="fa-regular fa-calendar-xmark" style="font-size: 32px; margin-bottom: 12px; display: block;"></i>
                                Não há programação para esta data.
                            </p>
                    <% } %>
                </div>

            </div>
        </div>
    </main>
</div>

</body>
</html>