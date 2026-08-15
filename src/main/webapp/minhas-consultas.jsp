<%@page import="com.example.main.models.Perfil"%>
<%@page import="com.example.main.models.Consulta"%>
<%@page import="java.util.HashSet"%>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Minhas Consultas</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* Estilos específicos para a tela de Minhas Consultas */
        .header-clean { padding: 32px 40px 0 40px; display: flex; justify-content: space-between; align-items: center; }
        .header-clean h2 { font-size: 24px; color: #2D3748; display: flex; align-items: center; gap: 12px; }
        .header-clean h2 i { color: #12A388; cursor: pointer; }
        .header-clean .btn-sino { font-size: 24px; color: #A0AEC0; cursor: pointer; }
        
        .tabs-container { padding: 24px 40px 0 40px; display: flex; gap: 32px; border-bottom: 2px solid #E2E8F0; margin-bottom: 32px; }
        .tab-item { font-size: 16px; font-weight: bold; color: #A0AEC0; padding-bottom: 12px; cursor: pointer; border-bottom: 3px solid transparent; text-decoration: none; }
        .tab-item.active { color: #12A388; border-bottom: 3px solid #12A388; }
        .tab-item:hover:not(.active) { color: #718096; }

        /* =========================================
           ABA 1: GRID DE ATIVAS 
           ========================================= */
        .consultas-grid { padding: 0 40px 40px 40px; display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 24px; }
        
        .consulta-grid-card { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; padding: 24px; display: flex; flex-direction: column; justify-content: space-between; min-height: 140px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .cgc-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 4px; }
        .cgc-nome { font-size: 18px; font-weight: bold; color: #2D3748; }
        .cgc-especialidade { font-size: 14px; color: #A0AEC0; margin-bottom: 24px; }
        .cgc-footer { display: flex; justify-content: space-between; align-items: center; }
        .cgc-data { font-size: 14px; color: #4A5568; display: flex; align-items: center; gap: 8px; font-weight: bold; }
        .cgc-data i { color: #A0AEC0; }
        
        .btn-cancelar { background: transparent; border: 1px solid #FC8181; color: #E53E3E; padding: 6px 16px; border-radius: 8px; font-size: 12px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-listaEspera { background: #12A388; border: 1px solid white; color: white; padding: 4px 16px; border-radius: 8px; font-size: 11px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-listaEspera:hover { background: white; border: 1px solid #12A388; color: #12A388; padding: 4px 16px; border-radius: 8px; font-size: 11px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-cancelar:hover { background: #FFF5F5; }
        .badge-confirmada { background-color: #E6FFFA; color: #12A388; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-pendente-card { background-color: #FFF3E0; color: #ED8936; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        
        .card-nova-consulta { background: #FFFFFF; border: 2px dashed #E2E8F0; border-radius: 12px; padding: 24px; display: flex; flex-direction: column; justify-content: center; align-items: center; cursor: pointer; min-height: 140px; transition: 0.2s;}
        .card-nova-consulta:hover { border-color: #12A388; background: #FAFEFD; }
        .cnc-badge { background-color: #E6FFFA; color: #12A388; padding: 8px 24px; border-radius: 20px; font-size: 14px; font-weight: bold; margin-bottom: 16px; }
        .cnc-icon { font-size: 32px; color: #FC8181; }

        /* =========================================
           ABA 2: HISTÓRICO (TABELA) 
           ========================================= */
        #conteudo-historico { padding: 0 40px 40px 40px; display: none; /* Oculto por padrão */ }
        
        .search-container { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; justify-content: center; }
        .search-container label { font-size: 14px; color: #A0AEC0; font-weight: bold; }
        .search-input { padding: 10px 16px; border: 1px solid #E2E8F0; border-radius: 8px; outline: none; width: 300px; font-size: 14px; }
        .search-input:focus { border-color: #12A388; }

        .historico-table-wrapper { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .historico-table { width: 100%; border-collapse: collapse; }
        .historico-table thead { background-color: #E6FFFA; }
        .historico-table th { padding: 16px; text-align: left; font-size: 14px; color: #12A388; font-weight: bold; }
        .historico-table td { padding: 16px; font-size: 14px; color: #2D3748; border-bottom: 1px solid #E2E8F0; font-weight: 600; }
        .historico-table tr:last-child td { border-bottom: none; }
        
        .btn-relatorio { background: transparent; border: 1px solid #12A388; color: #12A388; padding: 6px 16px; border-radius: 20px; font-size: 12px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-relatorio:hover { background: #E6FFFA; }
        
        .badge-realizada { background-color: #E6FFFA; color: #12A388; padding: 6px 12px; border-radius: 12px; font-size: 12px; font-weight: bold; display: inline-block; }
        .badge-cancelada { background-color: #FFF5F5; color: #E53E3E; padding: 6px 12px; border-radius: 12px; font-size: 12px; font-weight: bold; display: inline-block; }

        .btn-exportar { display: block; width: 100%; background-color: #12A388; color: white; border: none; padding: 16px; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; margin-top: 24px; transition: 0.2s; text-align: center; }
        .btn-exportar:hover { background-color: #0F8A73; }
        
        @media print {
            /* 1. Oculta a barra lateral */
            .sidebar {
                display: none !important;
            }

            /* 2. Expande a área principal para ocupar 100% da folha */
            .main-content {
                margin-left: 0 !important; 
                padding: 0 !important;
                width: 100% !important;
                background-color: #FFFFFF !important;
            }

            /* 3. Oculta botões, abas e barra de pesquisa no papel */
            .btn-exportar,
            .search-container,
            .tabs-container,
            .header-clean i {
                display: none !important;
            }

            /* 4. Remove sombras para um visual mais limpo (e economizar tinta) */
            .historico-table-wrapper {
                box-shadow: none !important;
                border: 1px solid #000 !important; /* Borda mais definida para o papel */
            }

            .historico-table th, .historico-table td {
                color: #000 !important; /* Força texto preto no relatório */
            }
        }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <!-- BARRA LATERAL -->
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="consultas" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
            <a href="minhas-consultas" class="nav-item active"><i class="fa-solid fa-notes-medical"></i> Consultas</a>
            <a href="/cliniflow/editar-perfil.jsp" class="nav-item"><i class="fa-solid fa-user"></i> Perfil</a>
            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
            <a href="#" class="nav-item"><i class="fa-solid fa-hourglass-start"></i> Lista(s) de Espera</a>
        </ul>
        <a href="index.html" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;"><i class="fa-solid fa-arrow-right-from-bracket"></i> Sair</a>
    </aside>

    <!-- ÁREA PRINCIPAL -->
    <main class="main-content" style="background-color: #F7FAFC;">
        
        <header class="header-clean">
            <h2><i class="fa-solid fa-chevron-left" onclick="history.back()"></i> Minhas Consultas</h2>
            <i class="fa-regular fa-bell btn-sino"></i>
        </header>

        <!-- Navegação em Abas (Adicionado IDs e onclick) -->
        <div class="tabs-container">
            <a href="#" id="tab-ativas" class="tab-item active" onclick="switchTab('ativas')">Ativas</a>
            <a href="#" id="tab-historico" class="tab-item" onclick="switchTab('historico')">Histórico</a>
        </div>

        <!-- ==============================================
             CONTEÚDO DA ABA: ATIVAS
             ============================================== -->
        <div id="conteudo-ativas" class="consultas-grid">
            <%
                @SuppressWarnings("unchecked")
                HashSet<Consulta> lista = (HashSet<Consulta>) request.getAttribute("consultasUsuarioLogado");
                if (lista != null && !lista.isEmpty()) {
                    for (Consulta c : lista) {
                        String statusStr = c.getStatusConsulta() != null ? c.getStatusConsulta().name() : "PENDENTE";
                        String classeBadge = "badge-pendente-card";
                        String textoBadge = "Pendente";
                        
                        if ("CANCELADA".equalsIgnoreCase(statusStr)) {
                        	classeBadge = "badge-cancelada";
                            textoBadge = "Cancelada";
                        }
                        if ("CONFIRMADA".equalsIgnoreCase(statusStr)) {
                        	classeBadge = "badge-confirmada";
                            textoBadge = "Confirmada";
                        }
                        
                        String nomeMedico = "Dr(a). Indefinido";
                        if (c.getMedicoConsulta() != null && c.getMedicoConsulta().getUsuario() != null) {
                            nomeMedico = "Dr(a). " + c.getMedicoConsulta().getUsuario().getNomeUsuario();
                        }
                        
                        String especialidade = "Clínico Geral"; 
                        String dataFormatada = c.getDataHoraInicioConsulta() != null ? c.getDataHoraInicioConsulta().toString().replace("T", ", ") : "Data não definida";
                        if (textoBadge.equals("Agendada") || textoBadge.equals("Pendente")) {
                        	
                        
            %>
            
                    <div class="consulta-grid-card">
                        <div>
                            <div class="cgc-header">
                                <span class="cgc-nome"><%= nomeMedico %></span>
                                <span class="<%= classeBadge %>"><%= textoBadge %></span>
                            </div>
                            <div class="cgc-especialidade"><%= especialidade %></div>
                        </div>
                        <div class="cgc-footer">
                            <span class="cgc-data"><i class="fa-regular fa-calendar"></i> <%= dataFormatada %></span>
                            <button class="btn-cancelar">Cancelar</button>
                            <form action="lista-espera" method="GET">
                            	<input type="hidden" value=<%=c.getIdConsulta() %> name="id_consulta">
                            	<button class="btn-listaEspera" type="submit">Lista de espera</button>
                            </form>
                            
                            
                        </div>
                    </div>
            <%
                     	}
                    }
                } 
            %>

            <div class="card-nova-consulta" onclick="window.location.href='agendamento'">
                <div class="cnc-badge">Nova Consulta</div>
                <i class="fa-regular fa-calendar-plus cnc-icon"></i>
            </div>
        </div>

        <!-- ==============================================
             CONTEÚDO DA ABA: HISTÓRICO
             ============================================== -->
        <div id="conteudo-historico">
            
            <div class="search-container">
                <label>Buscar por nome:</label>
                <input type="text" class="search-input" placeholder="digite um nome...">
            </div>

            <div class="historico-table-wrapper">
                <table class="historico-table">
                    <thead>
                        <tr>
                            <th>Médico</th>                            
                            <th>Especialidade</th>
                            <th>Ação</th>
                            <th>Status <i class="fa-solid fa-chevron-down" style="font-size: 10px; cursor: pointer;"></i></th>
                            <th>Data/Hora</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Exemplo estático (Você pode implementar o foreach do Java aqui futuramente) -->
                        <%
                        	HashSet<Consulta> listaHistorico = (HashSet<Consulta>) request.getAttribute("consultasUsuarioLogado");
                        	for(Consulta c:listaHistorico) { 
                        		String statusStr = c.getStatusConsulta() != null ? c.getStatusConsulta().name() : "PENDENTE";
                                String classeBadge = "badge-pendente-card";
                                String textoBadge = "Pendente";
                                
                                if ("CANCELADA".equalsIgnoreCase(statusStr)) {
                                	classeBadge = "badge-cancelada";
                                    textoBadge = "Cancelada";
                                }
                                if ("CONFIRMADA".equalsIgnoreCase(statusStr)) {
                                	classeBadge = "badge-confirmada";
                                    textoBadge = "Confirmada";
                                }
                                
                        %>
                        <tr>                            
                            <td><%=c.getMedicoConsulta().getUsuario().getNomeUsuario() + " " + c.getMedicoConsulta().getUsuario().getSobrenomeUsuario() %></td>
                            <td>Clínico Geral</td>
                            <td><button class="btn-relatorio">Ver Relatório</button></td>
                            <td><span class="<%=classeBadge %>"><%=textoBadge %></span></td>
                            <td><%=c.getDataHoraInicioConsulta() %></td>
                        </tr>                      
                        <%} %>
                    </tbody>
                </table>
            </div>

            <button class="btn-exportar" onclick="window.print()"><i class="fa-solid fa-download"></i> Exportar / Imprimir</button>

        </div>

    </main>
</div>

<!-- Script para alternar as abas dinamicamente sem recarregar a página -->
<script>
    function switchTab(tabName) {
        // IDs das abas
        const tabAtivas = document.getElementById('tab-ativas');
        const tabHistorico = document.getElementById('tab-historico');
        
        // IDs dos conteúdos
        const conteudoAtivas = document.getElementById('conteudo-ativas');
        const conteudoHistorico = document.getElementById('conteudo-historico');

        if (tabName === 'ativas') {
            tabAtivas.classList.add('active');
            tabHistorico.classList.remove('active');
            
            conteudoAtivas.style.display = 'grid';
            conteudoHistorico.style.display = 'none';
        } else if (tabName === 'historico') {
            tabHistorico.classList.add('active');
            tabAtivas.classList.remove('active');
            
            conteudoAtivas.style.display = 'none';
            conteudoHistorico.style.display = 'block';
        }
    }
    
    
</script>

</body>
</html>