<%@page import="jdk.internal.org.jline.terminal.TerminalBuilder.SystemOutput"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.example.main.models.Perfil"%>
<%@page import="com.example.main.models.Consulta"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    @SuppressWarnings("unchecked")
    HashSet<Consulta> listaCompleta = (HashSet<Consulta>) request.getAttribute("consultasUsuarioLogado");
    HashSet<Consulta> listaAtivas = new HashSet<>();
    HashSet<Consulta> listaHistorico = new HashSet<>();
    
    if (listaCompleta != null && !listaCompleta.isEmpty()) {
        for (Consulta c : listaCompleta) {
            String status = c.getStatusConsulta() != null ? c.getStatusConsulta().name() : "";
            if ("CANCELADA".equalsIgnoreCase(status) || "CONCLUIDA".equalsIgnoreCase(status) || "REALIZADA".equalsIgnoreCase(status)) {
                listaHistorico.add(c);
            } else {
                listaAtivas.add(c);
            }
        }
    }

    DateTimeFormatter formatadorBR = DateTimeFormatter.ofPattern("dd/MM/yyyy 'às' HH:mm");
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
        body.home-body, .dashboard-layout { height: 100vh; overflow: hidden; margin: 0; }
        .main-content { display: flex; flex-direction: column; height: 100vh; overflow: hidden; background-color: #F7FAFC; }
        
        .header-clean, .tabs-container { flex-shrink: 0; }
        
        .scroll-area-consultas { flex-grow: 1; overflow-y: auto; overflow-x: hidden; padding-bottom: 40px; min-height: 0; }
        .scroll-area-consultas::-webkit-scrollbar { width: 6px; }
        .scroll-area-consultas::-webkit-scrollbar-thumb { background-color: #CBD5E0; border-radius: 4px; }

        .header-clean { padding: 32px 40px 0 40px; display: flex; justify-content: space-between; align-items: center; }
        .header-clean h2 { font-size: 24px; color: #2D3748; margin: 0; }
        .header-clean .btn-sino { font-size: 24px; color: #A0AEC0; cursor: pointer; transition: 0.2s; }
        .header-clean .btn-sino:hover { color: #2D3748; }
        
        .tabs-container { padding: 24px 40px 0 40px; display: flex; gap: 32px; border-bottom: 2px solid #E2E8F0; margin-bottom: 24px; }
        .tab-item { font-size: 16px; font-weight: bold; color: #A0AEC0; padding-bottom: 12px; cursor: pointer; border-bottom: 3px solid transparent; text-decoration: none; transition: 0.2s; }
        .tab-item.active { color: #12A388; border-bottom: 3px solid #12A388; }
        .tab-item:hover:not(.active) { color: #718096; }

        .consultas-grid { padding: 0 40px; display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 24px; }
        
        .consulta-grid-card { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; padding: 24px; display: flex; flex-direction: column; gap: 16px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .cgc-header { display: flex; justify-content: space-between; align-items: flex-start; }
        .cgc-medico-info { display: flex; flex-direction: column; gap: 4px; }
        .cgc-nome { font-size: 18px; font-weight: bold; color: #2D3748; margin: 0; }
        .cgc-especialidade { font-size: 13px; color: #A0AEC0; margin: 0; }
        
        .cgc-data { font-size: 14px; color: #4A5568; display: flex; align-items: center; gap: 8px; font-weight: bold; background: #F7FAFC; padding: 10px; border-radius: 8px; border: 1px solid #EDF2F7; }
        .cgc-data i { color: #12A388; }
        
        .cgc-footer { display: flex; justify-content: flex-end; align-items: center; margin-top: auto; }
        .btn-cancelar { background: transparent; border: 1px solid #FC8181; color: #E53E3E; padding: 8px 16px; border-radius: 8px; font-size: 12px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-cancelar:hover { background: #FFF5F5; }

        /* REGRAS DAS CORES DAS BADGES */
        .badge-agendada { background-color: #E6FFFA; color: #12A388; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge-espera { background-color: #FFFDF5; color: #DD6B20; border: 1px solid #FEEBC8; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge-cancelada { background-color: #FFF5F5; color: #E53E3E; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge-concluida { background-color: #F0FFF4; color: #22543D; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }

        #conteudo-historico { padding: 0 40px; display: none; }
        .search-container { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
        .search-input { padding: 12px 16px; border: 1px solid #E2E8F0; border-radius: 8px; outline: none; width: 100%; max-width: 400px; font-size: 14px; transition: 0.2s; }
        .search-input:focus { border-color: #12A388; box-shadow: 0 0 0 3px rgba(18, 163, 136, 0.1); }

        .historico-table-wrapper { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.02); margin-bottom: 24px; }
        .historico-table { width: 100%; border-collapse: collapse; }
        .historico-table thead { background-color: #F7FAFC; border-bottom: 2px solid #E2E8F0; }
        .historico-table th { padding: 16px; text-align: left; font-size: 13px; color: #718096; font-weight: bold; text-transform: uppercase; }
        .historico-table td { padding: 16px; font-size: 14px; color: #2D3748; border-bottom: 1px solid #E2E8F0; font-weight: 500; }
        .historico-table tr:last-child td { border-bottom: none; }
        
        .btn-relatorio { background: transparent; border: 1px solid #12A388; color: #12A388; padding: 6px 16px; border-radius: 20px; font-size: 12px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-relatorio:hover { background: #E6FFFA; }

        .btn-exportar { display: flex; align-items: center; justify-content: center; gap: 8px; background-color: #2D3748; color: white; border: none; padding: 12px 24px; border-radius: 8px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; margin: 0 auto; width: fit-content; }
        .btn-exportar:hover { background-color: #1A202C; }
        
        /* --- ESTILOS DO RELATÓRIO ESPECÍFICO DE IMPRESSÃO --- */
        .print-modal-area { display: none; }

        @media print {
            .sidebar, .btn-exportar, .search-container, .tabs-container, .btn-agendar, .header-clean .btn-sino { display: none !important; }
            .main-content { margin-left: 0 !important; padding: 0 !important; width: 100% !important; background-color: #FFFFFF !important; height: auto !important; overflow: visible !important; }
            .historico-table-wrapper { box-shadow: none !important; border: 1px solid #000 !important; }
            .historico-table th, .historico-table td { color: #000 !important; }
            .scroll-area-consultas { overflow: visible !important; height: auto !important; }

            /* Quando for impressão específica, oculta a página normal */
            body.print-specific .dashboard-layout { display: none !important; }
            
            /* Exibe e formata apenas a área do relatório */
            body.print-specific .print-modal-area { 
                display: block !important; 
                width: 100%; 
                max-width: 600px; 
                margin: 0 auto; 
                padding: 32px; 
                border: 1px solid #E2E8F0; 
                border-radius: 16px;
                font-family: Arial, sans-serif;
            }
            
            /* Forçar a impressão das cores de fundo das badges */
            * {
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }

            .print-header { display: flex; align-items: center; border-bottom: 1px solid #E2E8F0; padding-bottom: 16px; margin-bottom: 24px; }
            .print-header h3 { margin: 0; font-size: 20px; color: #2D3748; display: flex; align-items: center; gap: 10px; }
            .detail-row { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px dashed #EDF2F7; }
            .detail-row:last-child { border-bottom: none; }
            .detail-label { font-size: 13px; color: #718096; font-weight: bold; text-transform: uppercase; }
            .detail-value { font-size: 15px; color: #2D3748; font-weight: 500; text-align: right; }
        }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="home" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
            <a href="minhas-consultas" class="nav-item active"><i class="fa-solid fa-notes-medical"></i> Consultas</a>
            <a href="minha-lista-espera" class="nav-item"><i class="fa-solid fa-hourglass-start"></i> Lista(s) de Espera</a>
            <a href="editar-perfil" class="nav-item"><i class="fa-solid fa-user"></i> Perfil</a>
            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
        </ul>
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Tem certeza que deseja sair do sistema?');"><i class="fa-solid fa-arrow-right-from-bracket"></i> Sair</a>
    </aside>

    <main class="main-content">
        
        <header class="header-clean">
            <h2>Minhas Consultas</h2>
            <div style="display: flex; align-items: center; gap: 24px;">
                <button class="btn-agendar" onclick="window.location.href='agendamento'">
                    <i class="fa-solid fa-plus"></i> Nova Consulta
                </button>
                <i class="fa-regular fa-bell btn-sino"></i>
            </div>
        </header>

        <div class="tabs-container">
            <a href="#" id="tab-ativas" class="tab-item active" onclick="switchTab('ativas')">Ativas</a>
            <a href="#" id="tab-historico" class="tab-item" onclick="switchTab('historico')">Histórico</a>
        </div>

        <div class="scroll-area-consultas">
            
            <div id="conteudo-ativas" class="consultas-grid">
                <%
                    if (listaAtivas != null && !listaAtivas.isEmpty()) {
                        for (Consulta c : listaAtivas) {
                            String statusStr = c.getStatusConsulta() != null ? c.getStatusConsulta().name() : "PENDENTE";
                            
                            String classeBadge = "badge-agendada"; 
                            String textoBadge = "Agendada";
                            
                            if ("ESPERA".equalsIgnoreCase(statusStr) || "PENDENTE".equalsIgnoreCase(statusStr)) {
                                classeBadge = "badge-espera";
                                textoBadge = "Lista de Espera";
                            }
                            
                            String nomeMedico = "Dr(a). Indefinido";
                            if (c.getMedicoConsulta() != null && c.getMedicoConsulta().getUsuario() != null) {
                                nomeMedico = "Dr(a). " + c.getMedicoConsulta().getUsuario().getNomeUsuario() + " " + c.getMedicoConsulta().getUsuario().getSobrenomeUsuario();
                            }
                            
                            String dataFormatada = "Data não definida";
                            if (c.getDataHoraInicioConsulta() != null) {
                                dataFormatada = c.getDataHoraInicioConsulta().format(formatadorBR);
                            }
                %>
                        <div class="consulta-grid-card">
                            <div class="cgc-header">
                                <div class="cgc-medico-info">
                                    <h4 class="cgc-nome"><%= nomeMedico %></h4>
                                    <p class="cgc-especialidade">Consulta Médica</p>
                                </div>
                                <span class="<%= classeBadge %>"><%= textoBadge %></span>
                            </div>
                            
                            <div class="cgc-data">
                                <i class="fa-regular fa-calendar-check"></i> <%= dataFormatada %>
                            </div>
                            
                            <div class="cgc-footer">
                                <form action="minhas-consultas" method="POST" onsubmit="return confirm('Tem certeza que deseja cancelar esta consulta?');">
                                    <input type="hidden" name="acao" value="cancelar">
                                    <input type="hidden" name="id_consulta" value="<%= c.getIdConsulta() %>">
                                    <button class="btn-cancelar" type="submit">Cancelar Consulta</button>
                                </form>
                            </div>
                        </div>
                <%
                        }
                    } else {
                %>
                    <p style="color: #A0AEC0; font-size: 14px; grid-column: 1 / -1;">Você não possui consultas ativas no momento.</p>
                <%
                    } 
                %>
            </div>

            <div id="conteudo-historico">
                <div class="search-container">
                    <i class="fa-solid fa-magnifying-glass" style="color: #A0AEC0;"></i>
                    <input type="text" id="inputBusca" class="search-input" placeholder="Buscar consulta pelo nome do médico..." onkeyup="filtrarHistorico()">
                </div>

                <div class="historico-table-wrapper">
                    <table class="historico-table" id="tabelaHistorico">
                        <thead>
                            <tr>
                                <th>Médico</th>                             
                                <th>Especialidade</th>
                                <th>Data / Hora</th>
                                <th>Status</th>
                                <th>Ação</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (listaHistorico != null && !listaHistorico.isEmpty()) {
                                    for(Consulta c : listaHistorico) { 
                                        String statusStr = c.getStatusConsulta() != null ? c.getStatusConsulta().name() : "CONCLUIDA";
                                        String classeBadge = "badge-concluida";
                                        String textoBadge = "Concluída";
                                        
                                        if ("CANCELADA".equalsIgnoreCase(statusStr)) {
                                            classeBadge = "badge-cancelada";
                                            textoBadge = "Cancelada";
                                        }
                                        
                                        String dataFormatadaHistorico = "";
                                        if (c.getDataHoraInicioConsulta() != null) {
                                            dataFormatadaHistorico = c.getDataHoraInicioConsulta().format(formatadorBR);
                                        }
                                        
                                        @SuppressWarnings("unchecked")
                                        HashMap<Integer, String> mapaEspecialidades = (HashMap<Integer, String>) request.getAttribute("mapaEspecialidades");
                                        String especialidade = "Clínico Geral";
                                        if (mapaEspecialidades != null && c.getMedicoConsulta() != null && mapaEspecialidades.containsKey(c.getMedicoConsulta().getIdPerfil())) {
                                            especialidade = mapaEspecialidades.get(c.getMedicoConsulta().getIdPerfil());
                                        }
                                        
                                        // Variaveis de dados para o relatorio de impressao especifico
                                        String medicoNome = "Dr(a). " + c.getMedicoConsulta().getUsuario().getNomeUsuario() + " " + c.getMedicoConsulta().getUsuario().getSobrenomeUsuario();
                                        String pacienteNome = usuarioLogado.getUsuario().getNomeUsuario() + " " + usuarioLogado.getUsuario().getSobrenomeUsuario();
                            %>
                            <tr>                                
                                <td><%= medicoNome %></td>
                                <td><%= especialidade %></td>
                                <td><%= dataFormatadaHistorico %></td>
                                <td><span class="<%= classeBadge %>"><%= textoBadge %></span></td>
                                <td>
                                    <!-- Botão com o onclick ativando a função de impressão -->
                                    <button class="btn-relatorio" onclick="imprimirRelatorioEspecifico('<%= pacienteNome %>', '<%= medicoNome %>', '<%= especialidade %>', '<%= dataFormatadaHistorico %>', '<%= textoBadge %>', '<%= classeBadge %>')">
                                        Ver Relatório
                                    </button>
                                </td>
                            </tr>                      
                            <%      }
                                } else {
                            %>
                            <tr>
                                <td colspan="5" style="text-align: center; color: #A0AEC0; padding: 32px;">Nenhum histórico de consultas encontrado.</td>
                            </tr>
                            <%  } %>
                        </tbody>
                    </table>
                </div>

                <button class="btn-exportar" onclick="window.print()">
                    <i class="fa-solid fa-print"></i> Imprimir Relatório Geral
                </button>

            </div>
        </div>
    </main>
</div>

<!-- ÁREA EXCLUSIVA PARA A IMPRESSÃO DO RELATÓRIO ESPECÍFICO -->
<div class="print-modal-area" id="areaRelatorioImpressao">
    <div class="print-header">
        <h3><i class="fa-solid fa-stethoscope" style="color: #12A388;"></i> Detalhes da Consulta</h3>
    </div>
    
    <div>
        <div class="detail-row">
            <span class="detail-label">Paciente</span>
            <span class="detail-value" id="print-paciente">--</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Médico Responsável</span>
            <span class="detail-value" id="print-medico">--</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Especialidade</span>
            <span class="detail-value" id="print-especialidade">--</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Data e Horário</span>
            <span class="detail-value" id="print-data">--</span>
        </div>
        <div class="detail-row" style="margin-top: 8px;">
            <span class="detail-label">Status Atual</span>
            <span id="print-status" class="badge-agendada">--</span>
        </div>
    </div>
</div>

<script>
    function switchTab(tabName) {
        const tabAtivas = document.getElementById('tab-ativas');
        const tabHistorico = document.getElementById('tab-historico');
        
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

    function filtrarHistorico() {
        let input = document.getElementById("inputBusca");
        let filtro = input.value.toUpperCase();
        let tabela = document.getElementById("tabelaHistorico");
        let linhas = tabela.getElementsByTagName("tr");

        for (let i = 1; i < linhas.length; i++) {
            let colunaMedico = linhas[i].getElementsByTagName("td")[0]; 
            
            if (colunaMedico) {
                let textoOriginal = colunaMedico.textContent || colunaMedico.innerText;
                if (textoOriginal.toUpperCase().indexOf(filtro) > -1) {
                    linhas[i].style.display = "";
                } else {
                    linhas[i].style.display = "none";
                }
            }
        }
    }

    // NOVA FUNÇÃO: Preenche os dados e imprime apenas o relatório específico
    function imprimirRelatorioEspecifico(paciente, medico, especialidade, data, textoStatus, classeBadge) {
        // Preenche os dados no HTML oculto
        document.getElementById('print-paciente').innerText = paciente;
        document.getElementById('print-medico').innerText = medico;
        document.getElementById('print-especialidade').innerText = especialidade;
        document.getElementById('print-data').innerText = data;
        
        // Configura a cor e o texto do status
        let badgeElement = document.getElementById('print-status');
        badgeElement.className = ''; // Limpa as classes antigas
        badgeElement.classList.add(classeBadge);
        badgeElement.innerText = textoStatus;
        
        // Adiciona a classe no body para ativar o CSS exclusivo de impressão do modal
        document.body.classList.add('print-specific');
        
        // Aciona o diálogo de impressão do navegador
        window.print();
        
        // Remove a classe após fechar a tela de impressão
        setTimeout(() => {
            document.body.classList.remove('print-specific');
        }, 500);
    }
</script>

</body>
</html>