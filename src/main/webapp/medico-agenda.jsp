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
		                
		                <!-- carrossel apenas com dias de consulta -->
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