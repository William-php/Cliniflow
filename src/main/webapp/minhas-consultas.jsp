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
            String status = c.getStatusConsulta() != null ? c.getStatusConsulta().name().toUpperCase() : "";
            
            if ("CANCELADA".equals(status) || "CONCLUIDA".equals(status) || "REALIZADA".equals(status)) {
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
		                                        Imprimir Relatório
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
		
		    function imprimirRelatorioEspecifico(paciente, medico, especialidade, data, textoStatus, classeBadge) {

		        document.getElementById('print-paciente').innerText = paciente;
		        document.getElementById('print-medico').innerText = medico;
		        document.getElementById('print-especialidade').innerText = especialidade;
		        document.getElementById('print-data').innerText = data;
		        
		        let badgeElement = document.getElementById('print-status');
		        badgeElement.className = '';
		        badgeElement.classList.add(classeBadge);
		        badgeElement.innerText = textoStatus;
		        
		        document.body.classList.add('print-specific');
		        
		        window.print();
		        
		        setTimeout(() => {
		            document.body.classList.remove('print-specific');
		        }, 500);
		    }
		</script>
	
	</body>
</html>