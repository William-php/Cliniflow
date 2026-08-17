<%@page import="com.example.main.models.Perfil"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    DateTimeFormatter formatadorBR = DateTimeFormatter.ofPattern("dd/MM/yyyy 'às' HH:mm");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Lista de Espera</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* =========================================================================
           O MESMO CSS DA VERSÃO ANTERIOR (Mova para o style.css se quiser)
           ========================================================================= */
        body.home-body, .dashboard-layout { height: 100vh; overflow: hidden; margin: 0; }
        .main-content { display: flex; flex-direction: column; height: 100vh; overflow: hidden; background-color: #F7FAFC; }
        .header-clean, .subtitle-area { flex-shrink: 0; }
        .scroll-area-espera { flex-grow: 1; overflow-y: auto; overflow-x: hidden; padding-bottom: 40px; min-height: 0; }
        .scroll-area-espera::-webkit-scrollbar { width: 6px; }
        .scroll-area-espera::-webkit-scrollbar-thumb { background-color: #CBD5E0; border-radius: 4px; }
        .header-clean { padding: 32px 40px 8px 40px; display: flex; justify-content: space-between; align-items: center; }
        .header-clean h2 { font-size: 24px; color: #2D3748; margin: 0; }
        .header-clean .btn-sino { font-size: 24px; color: #A0AEC0; cursor: pointer; transition: 0.2s; }
        .header-clean .btn-sino:hover { color: #2D3748; }
        .subtitle-area { padding: 0 40px 32px 40px; }
        .subtitle-area p { color: #A0AEC0; font-size: 14px; margin: 0; }
        .waitlist-container { padding: 0 40px; display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 24px; }
        .card-espera { background-color: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; padding: 24px; display: flex; align-items: center; gap: 16px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); transition: 0.2s; }
        .card-espera:hover { border-color: #12A388; }
        .posicao-badge { background-color: #E6FFFA; color: #12A388; font-weight: bold; border-radius: 50%; width: 48px; height: 48px; display: flex; justify-content: center; align-items: center; font-size: 16px; flex-shrink: 0; border: 2px solid #C6F6D5; }
        .info-medico { flex-grow: 1; display: flex; flex-direction: column; gap: 4px; }
        .info-medico h4 { color: #2D3748; font-size: 18px; margin: 0; }
        .info-medico p { color: #718096; font-size: 13px; margin: 0; }
        .info-data { font-size: 13px; color: #4A5568; font-weight: bold; display: flex; align-items: center; gap: 6px; margin: 8px 0; }
        .info-data i { color: #12A388; }
        .acoes-card { display: flex; justify-content: space-between; align-items: center; margin-top: 8px; }
        .badge-status { background-color: #FFF3E0; color: #ED8936; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .btn-sair-fila { color: #FC8181; font-size: 13px; font-weight: bold; cursor: pointer; border: none; background: none; padding: 0; transition: 0.2s; }
        .btn-sair-fila:hover { text-decoration: underline; color: #E53E3E; }
    </style>
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
                            
                            LocalDateTime dataHora = (LocalDateTime) fila.get("dataHora");
                            String dataFormatada = dataHora != null ? dataHora.format(formatadorBR) : "Data não definida";
                %>
                
                <div class="card-espera">
                    <div class="posicao-badge" title="Sua posição atual na fila">#<%= posicao %></div>
                    
                    <div class="info-medico">
                        <h4><%= nomeMedico %></h4>
                        <p>Clínico Geral</p>
                        
                        <div class="info-data">
                            <i class="fa-regular fa-calendar"></i> <%= dataFormatada %>
                        </div>
                        
                        <div class="acoes-card">
                            <span class="badge-status">Na Fila</span>
                            
                            <!-- Formulário Seguro passando o ID ÚNICO da fila -->
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