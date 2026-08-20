<%@page import="com.example.main.models.Perfil"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    DateTimeFormatter formatadorBR = DateTimeFormatter.ofPattern("dd/MM/yyyy 'às' HH:mm");
    
    //resgata o mapa de especialidades do Controller
    @SuppressWarnings("unchecked")
    HashMap<Integer, String> mapaEspecialidades = (HashMap<Integer, String>) request.getAttribute("mapaEspecialidades");
    if (mapaEspecialidades == null) mapaEspecialidades = new HashMap<>();
%>
<!DOCTYPE html>
<html lang="pt-BR">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>CliniFlow - Lista de Espera</title>
	    <link rel="stylesheet" href="css/style.css">
	    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
	</head>
	<body class="home-body">
		
		<div class="dashboard-layout">
		    
		    <aside class="sidebar">
		        <div class="sidebar-logo">Clini<span>Flow</span></div>
		        <ul class="nav-menu">
		            <a href="home" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
		            <a href="minhas-consultas" class="nav-item"><i class="fa-solid fa-notes-medical"></i> Consultas</a>
		            <a href="minha-lista-espera" class="nav-item active"><i class="fa-solid fa-hourglass-start"></i> Lista(s) de Espera</a>
		            <a href="/cliniflow/editar-perfil.jsp" class="nav-item"><i class="fa-solid fa-user"></i> Perfil</a>
		            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
		        </ul>
		        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Tem certeza que deseja sair do sistema?');">
		            <i class="fa-solid fa-arrow-right-from-bracket"></i> Sair
		        </a>
		    </aside>
		
		    <main class="main-content">
		        
		        <% 
		            String sucesso = request.getParameter("sucesso");
		            if ("espera".equals(sucesso)) { 
		        %>
		            <div id="toast-alerta" class="toast-sucesso" style="background-color: #FFFDF5; color: #DD6B20; border-color: #DD6B20; position: fixed; top: 24px; right: 40px; padding: 16px 24px; border-radius: 8px; border-width: 1px; border-style: solid; font-size: 14px; font-weight: bold; box-shadow: 0 4px 12px rgba(0,0,0,0.1); display: flex; align-items: center; justify-content: space-between; gap: 24px; z-index: 9999; transition: opacity 0.3s ease;">
		                <div style="display: flex; align-items: center; gap: 12px;">
		                    <i class="fa-solid fa-hourglass-half"></i> 
		                    <span>Você entrou na Lista de Espera desta consulta com sucesso!</span>
		                </div>
		                <i class="fa-solid fa-xmark" style="cursor: pointer; color: #DD6B20; font-size: 18px;" onclick="fecharToast()"></i>
		            </div>
		            <script>
		                setTimeout(fecharToast, 4000);
		                function fecharToast() {
		                    var toast = document.getElementById("toast-alerta");
		                    if(toast) { toast.style.opacity = "0"; setTimeout(() => toast.remove(), 300); }
		                }
		            </script>
		        <% } %>
		
		        <header class="header-clean">
		            <h2>Minhas Listas de Espera</h2>
		            <i class="fa-regular fa-bell btn-sino"></i>
		        </header>
		
		        <div class="subtitle-area">
		            <p>Acompanhe sua posição. Você será notificado automaticamente se uma vaga abrir.</p>
		        </div>
		
		        <div class="scroll-area-espera">
		            <div class="waitlist-container">
		                
		                <%
		                    @SuppressWarnings("unchecked")
		                    List<Map<String, Object>> filasDetalhadas = (List<Map<String, Object>>) request.getAttribute("filasDetalhadas");
		                    
		                    if (filasDetalhadas != null && !filasDetalhadas.isEmpty()) {
		                        for (Map<String, Object> fila : filasDetalhadas) {
		                            int idFila = (Integer) fila.get("idListaEspera");
		                            int posicao = (Integer) fila.get("posicao");
		                            String nomeMedico = (String) fila.get("nomeMedico");
		                            
		                            // Pega a Especialidade dinamicamente do Mapa
		                            int idMedico = fila.get("idMedico") != null ? (Integer) fila.get("idMedico") : 0;
		                            String especialidadeExibida = mapaEspecialidades.getOrDefault(idMedico, "Clínico Geral");
		                            
		                            LocalDateTime dataHora = (LocalDateTime) fila.get("dataHora");
		                            String dataFormatada = dataHora != null ? dataHora.format(formatadorBR) : "Data não definida";
		                %>
		                
		                <div class="card-espera">
		                    <div class="posicao-badge" title="Sua posição atual na fila">#<%= posicao %></div>
		                    
		                    <div class="info-medico">
		                        <h4><%= nomeMedico %></h4>
		                        <p><%= especialidadeExibida %></p>
		                        
		                        <div class="info-data">
		                            <i class="fa-regular fa-calendar"></i> <%= dataFormatada %>
		                        </div>
		                        
		                        <div class="acoes-card">
		                            <span class="badge-status">Na Fila</span>
		                            
		                            <form action="minha-lista-espera" method="POST" onsubmit="return confirm('Tem certeza que deseja sair desta fila de espera?');" style="margin: 0;">
		                                <input type="hidden" name="acao" value="sair_fila">
		                                <input type="hidden" name="id_lista_espera" value="<%= idFila %>">
		                                <button type="submit" class="btn-sair-fila">Sair da fila</button>
		                            </form>
		                        </div>
		                    </div>
		                </div>
		
		                <%
		                        }
		                    } else {
		                %>
		                    <div style="grid-column: 1 / -1; text-align: center; margin-top: 40px;">
		                        <i class="fa-solid fa-clipboard-check" style="font-size: 48px; color: #E2E8F0; margin-bottom: 16px;"></i>
		                        <p style="color: #A0AEC0; font-size: 16px;">Você não está em nenhuma lista de espera no momento.</p>
		                    </div>
		                <%
		                    }
		                %>
		
		            </div>
		        </div>
		    </main>
		</div>
		
	</body>
</html>