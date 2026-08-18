<%@page import="com.example.main.models.Perfil"%>
<%@page import="com.example.main.models.Consulta"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.HashMap"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Perfil adminLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (adminLogado == null || adminLogado.getUsuario() == null || !adminLogado.getUsuario().isAdmUsuario()) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String sucesso = request.getParameter("sucesso");
    DateTimeFormatter formatoBR = DateTimeFormatter.ofPattern("dd/MM/yyyy 'às' HH:mm");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Gerenciar Consultas</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body.home-body, .dashboard-layout { height: 100vh; overflow: hidden; margin: 0; }
        .main-content { display: flex; flex-direction: column; height: 100vh; overflow: hidden; background-color: #F7FAFC; position: relative; }
        
        .topbar-admin { background-color: #12A388; padding: 24px 40px; color: #FFFFFF; flex-shrink: 0; display: flex; justify-content: space-between; align-items: center; }
        .topbar-admin h2 { font-size: 22px; margin: 0; font-weight: 700; }

        .scroll-area-admin { flex-grow: 1; overflow-y: auto; overflow-x: hidden; padding: 32px 40px; min-height: 0; }
        .scroll-area-admin::-webkit-scrollbar { width: 6px; }
        .scroll-area-admin::-webkit-scrollbar-thumb { background-color: #CBD5E0; border-radius: 4px; }

        /* TOAST NOTIFICATION */
        .toast-sucesso { position: fixed; top: 24px; right: 40px; background-color: #E6FFFA; color: #12A388; padding: 16px 24px; border-radius: 8px; border: 1px solid #12A388; font-size: 14px; font-weight: bold; box-shadow: 0 4px 12px rgba(0,0,0,0.1); display: flex; align-items: center; justify-content: space-between; gap: 24px; z-index: 9999; transition: opacity 0.3s ease; }
        
        /* BARRA DE FERRAMENTAS PADRONIZADA */
        .toolbar-container { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px; }
        .toolbar-left { display: flex; gap: 16px; align-items: center; flex-wrap: wrap; }
        .search-box { position: relative; width: 350px; }
        .search-box i { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: #A0AEC0; }
        .search-box input { width: 100%; padding: 12px 16px 12px 40px; border: 1px solid #E2E8F0; border-radius: 8px; font-size: 14px; outline: none; transition: 0.2s; box-sizing: border-box; }
        .search-box input:focus { border-color: #12A388; box-shadow: 0 0 0 3px rgba(18, 163, 136, 0.1); }
        .filter-pills { display: flex; background-color: #EDF2F7; padding: 4px; border-radius: 8px; gap: 4px; }
        .pill-btn { background: transparent; border: none; padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: bold; color: #718096; cursor: pointer; transition: 0.2s; }
        .pill-btn.active { background-color: #FFFFFF; color: #2D3748; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }

        /* TABELA DE CONSULTAS */
        .table-wrapper { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .admin-table { width: 100%; border-collapse: collapse; }
        .admin-table thead { background-color: #F7FAFC; border-bottom: 2px solid #E2E8F0; }
        .admin-table th { padding: 16px 24px; text-align: left; font-size: 12px; color: #718096; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; }
        .admin-table td { padding: 16px 24px; font-size: 14px; color: #2D3748; border-bottom: 1px solid #E2E8F0; vertical-align: middle; }
        .admin-table tr:last-child td { border-bottom: none; }
        
        .user-cell { display: flex; flex-direction: column; gap: 4px; }
        .user-name { font-weight: 700; color: #2D3748; }
        .user-sub { font-size: 12px; color: #718096; }

        .btn-icon { background: transparent; border: none; color: #A0AEC0; font-size: 16px; cursor: pointer; transition: 0.2s; padding: 6px; border-radius: 6px; display: inline-flex; align-items: center; justify-content: center; text-decoration: none;}
        .btn-icon:hover { color: #2D3748; background-color: #EDF2F7; }

        /* BADGES */
        .badge-agendada { background-color: #E6FFFA; color: #12A388; padding: 6px 12px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge-cancelada { background-color: #FFF5F5; color: #E53E3E; padding: 6px 12px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge-concluida { background-color: #F0FFF4; color: #22543D; padding: 6px 12px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }

        /* MODAL DE DETALHES */
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background-color: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; opacity: 0; visibility: hidden; transition: 0.3s; }
        .modal-overlay.active { opacity: 1; visibility: visible; }
        .modal-content { background-color: #FFFFFF; border-radius: 16px; width: 100%; max-width: 500px; padding: 32px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); transform: translateY(20px); transition: 0.3s; }
        .modal-overlay.active .modal-content { transform: translateY(0); }
        .modal-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #E2E8F0; padding-bottom: 16px; margin-bottom: 24px; }
        .modal-header h3 { margin: 0; font-size: 20px; color: #2D3748; display: flex; align-items: center; gap: 10px; }
        .btn-close-modal { background: none; border: none; font-size: 20px; color: #A0AEC0; cursor: pointer; }
        
        .detail-row { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px dashed #EDF2F7; }
        .detail-row:last-child { border-bottom: none; }
        .detail-label { font-size: 13px; color: #718096; font-weight: bold; text-transform: uppercase; }
        .detail-value { font-size: 15px; color: #2D3748; font-weight: 500; text-align: right; }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="admin-home" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
            <a href="admin-usuarios" class="nav-item"><i class="fa-solid fa-users"></i> Usuários</a>
            <a href="admin-consultas" class="nav-item active"><i class="fa-solid fa-calendar-check"></i> Consultas</a>
            <a href="admin-agendas" class="nav-item"><i class="fa-solid fa-calendar-plus"></i> Agendas Médicas</a>
            <a href="admin-listas-espera" class="nav-item"><i class="fa-solid fa-hourglass-half"></i> Listas de Espera</a>
            <a href="editar-perfil" class="nav-item"><i class="fa-solid fa-user"></i> Meu Perfil</a>
        </ul>
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Sair do sistema?');"><i class="fa-solid fa-arrow-right-from-bracket"></i> Sair</a>
    </aside>

    <main class="main-content">
        
        <% if (sucesso != null) { %>
            <div id="toast-alerta" class="toast-sucesso">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <i class="fa-solid fa-circle-check"></i> 
                    <span>Status da consulta atualizado com sucesso!</span>
                </div>
                <i class="fa-solid fa-xmark" style="cursor: pointer; color: #12A388;" onclick="fecharToast()"></i>
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
            <h2>Gerenciar Consultas</h2>
            <i class="fa-regular fa-bell" style="font-size: 22px; cursor: pointer;"></i>
        </header>

        <div class="scroll-area-admin">
            
            <div class="toolbar-container">
                <div class="toolbar-left">
                    <div class="search-box">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="inputBusca" placeholder="Buscar paciente ou médico..." onkeyup="filtrarTabela()">
                    </div>

                    <div class="filter-pills">
                        <button class="pill-btn active" onclick="setFiltroStatus('TODAS', this)">Todas</button>
                        <button class="pill-btn" onclick="setFiltroStatus('AGENDADA', this)">Agendadas</button>
                        <button class="pill-btn" onclick="setFiltroStatus('CONCLUIDA', this)">Concluídas</button>
                        <button class="pill-btn" onclick="setFiltroStatus('CANCELADA', this)">Canceladas</button>
                    </div>
                </div>
            </div>

            <div class="table-wrapper">
                <table class="admin-table" id="tabelaConsultas">
                    <thead>
                        <tr>
                            <th>Paciente</th>
                            <th>Médico Responsável</th>
                            <th>Data e Hora</th>
                            <th>Status</th>
                            <th style="text-align: right;">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            @SuppressWarnings("unchecked")
                            HashSet<Consulta> listaConsultas = (HashSet<Consulta>) request.getAttribute("listaConsultas");
                            
                            @SuppressWarnings("unchecked")
                            HashMap<Integer, String> mapaEspecialidades = (HashMap<Integer, String>) request.getAttribute("mapaEspecialidades");
                            
                            if (listaConsultas != null && !listaConsultas.isEmpty()) {
                                for (Consulta c : listaConsultas) {
                                    String pacienteNome = c.getPacienteConsulta().getUsuario().getNomeUsuario() + " " + c.getPacienteConsulta().getUsuario().getSobrenomeUsuario();
                                    String medicoNome = "Dr(a). " + c.getMedicoConsulta().getUsuario().getNomeUsuario() + " " + c.getMedicoConsulta().getUsuario().getSobrenomeUsuario();
                                    
                                    // A MÁGICA VISUAL: Pega a especialidade real do mapa
                                    String especialidade = "Clínico Geral";
                                    if (mapaEspecialidades != null && c.getMedicoConsulta() != null && mapaEspecialidades.containsKey(c.getMedicoConsulta().getIdPerfil())) {
                                        especialidade = mapaEspecialidades.get(c.getMedicoConsulta().getIdPerfil());
                                    }
                                    
                                    String dataFormatada = c.getDataHoraInicioConsulta() != null ? c.getDataHoraInicioConsulta().format(formatoBR) : "Não definida";
                                    
                                    String statusRaw = c.getStatusConsulta() != null ? c.getStatusConsulta().name() : "AGENDADA";
                                    String classeBadge = "badge-agendada";
                                    String textoStatus = "Agendada";
                                    
                                    if ("CANCELADA".equalsIgnoreCase(statusRaw)) {
                                        classeBadge = "badge-cancelada"; textoStatus = "Cancelada";
                                    } else if ("CONCLUIDA".equalsIgnoreCase(statusRaw) || "REALIZADA".equalsIgnoreCase(statusRaw)) {
                                        classeBadge = "badge-concluida"; textoStatus = "Concluída";
                                        statusRaw = "CONCLUIDA"; 
                                    }
                        %>
                        <tr data-status="<%= statusRaw %>">
                            <td>
                                <div class="user-cell">
                                    <span class="user-name"><%= pacienteNome %></span>
                                    <span class="user-sub">Paciente</span>
                                </div>
                            </td>
                            <td>
                                <div class="user-cell">
                                    <span class="user-name" style="color: #4A5568;"><%= medicoNome %></span>
                                    <span class="user-sub"><%= especialidade %></span> <!-- Especialidade Real -->
                                </div>
                            </td>
                            <td style="font-weight: 500;"><%= dataFormatada %></td>
                            <td><span class="<%= classeBadge %>"><%= textoStatus %></span></td>
                            <td style="text-align: right; white-space: nowrap;">
                                
                                <!-- O Modal agora recebe a Especialidade real do banco de dados -->
                                <button class="btn-icon" title="Ver Detalhes" onclick="abrirModalDetalhes('<%= pacienteNome %>', '<%= medicoNome %>', '<%= especialidade %>', '<%= dataFormatada %>', '<%= textoStatus %>', '<%= classeBadge %>')">
                                    <i class="fa-regular fa-eye"></i>
                                </button>
                                
                                <% if ("AGENDADA".equalsIgnoreCase(statusRaw)) { %>
                                    <form action="admin-consultas" method="POST" style="display:inline;">
                                        <input type="hidden" name="acao" value="concluir">
                                        <input type="hidden" name="id_consulta" value="<%= c.getIdConsulta() %>">
                                        <button type="submit" class="btn-icon" title="Marcar como Concluída" style="color: #38A169;" onclick="return confirm('Confirmar a realização desta consulta?');"><i class="fa-solid fa-check"></i></button>
                                    </form>

                                    <form action="admin-consultas" method="POST" style="display:inline;">
                                        <input type="hidden" name="acao" value="cancelar">
                                        <input type="hidden" name="id_consulta" value="<%= c.getIdConsulta() %>">
                                        <button type="submit" class="btn-icon" title="Cancelar Consulta" style="color: #E53E3E;" onclick="return confirm('Deseja realmente cancelar esta consulta?');"><i class="fa-solid fa-ban"></i></button>
                                    </form>
                                <% } %>

                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                            <tr>
                                <td colspan="5" style="text-align: center; color: #A0AEC0; padding: 32px;">Nenhuma consulta encontrada no sistema.</td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

        </div>
    </main>
</div>

<!-- MODAL DE DETALHES DA CONSULTA -->
<div class="modal-overlay" id="modalDetalhes">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fa-solid fa-stethoscope" style="color: #12A388;"></i> Detalhes da Consulta</h3>
            <button class="btn-close-modal" onclick="fecharModalDetalhes()"><i class="fa-solid fa-xmark"></i></button>
        </div>
        
        <div>
            <div class="detail-row">
                <span class="detail-label">Paciente</span>
                <span class="detail-value" id="det-paciente">--</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Médico Responsável</span>
                <span class="detail-value" id="det-medico">--</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Especialidade</span>
                <span class="detail-value" id="det-especialidade">--</span> <!-- ID adicionado para o Javascript atualizar -->
            </div>
            <div class="detail-row">
                <span class="detail-label">Data e Horário</span>
                <span class="detail-value" id="det-data">--</span>
            </div>
            <div class="detail-row" style="margin-top: 8px;">
                <span class="detail-label">Status Atual</span>
                <span id="det-status" class="badge-agendada">--</span>
            </div>
        </div>
        
    </div>
</div>

<script>
    let filtroAtual = 'TODAS';

    function setFiltroStatus(status, elementoClicado) {
        filtroAtual = status;
        document.querySelectorAll('.pill-btn').forEach(btn => btn.classList.remove('active'));
        elementoClicado.classList.add('active');
        filtrarTabela();
    }

    function filtrarTabela() {
        let inputBusca = document.getElementById("inputBusca").value.toUpperCase();
        let tabela = document.getElementById("tabelaConsultas");
        let linhas = tabela.getElementsByTagName("tbody")[0].getElementsByTagName("tr");

        for (let i = 0; i < linhas.length; i++) {
            let linha = linhas[i];
            let statusLinha = linha.getAttribute("data-status");
            
            let celulaPaciente = linha.getElementsByTagName("td")[0];
            let celulaMedico = linha.getElementsByTagName("td")[1];
            
            if (celulaPaciente && celulaMedico) {
                let textoPaciente = celulaPaciente.textContent || celulaPaciente.innerText;
                let textoMedico = celulaMedico.textContent || celulaMedico.innerText;
                
                let matchBusca = (textoPaciente.toUpperCase().indexOf(inputBusca) > -1) || 
                                 (textoMedico.toUpperCase().indexOf(inputBusca) > -1);
                                 
                let matchStatus = (filtroAtual === 'TODAS' || filtroAtual === statusLinha);

                if (matchBusca && matchStatus) {
                    linha.style.display = "";
                } else {
                    linha.style.display = "none";
                }
            }
        }
    }

    // Função JS atualizada recebendo a especialidade e injetando no modal
    function abrirModalDetalhes(paciente, medico, especialidade, data, textoStatus, classeBadge) {
        document.getElementById('det-paciente').innerText = paciente;
        document.getElementById('det-medico').innerText = medico;
        document.getElementById('det-especialidade').innerText = especialidade; // A mágica visual acontece aqui!
        document.getElementById('det-data').innerText = data;
        
        let badgeElement = document.getElementById('det-status');
        badgeElement.className = ''; 
        badgeElement.classList.add(classeBadge);
        badgeElement.innerText = textoStatus;
        
        document.getElementById('modalDetalhes').classList.add('active');
    }

    function fecharModalDetalhes() { 
        document.getElementById('modalDetalhes').classList.remove('active'); 
    }
</script>

</body>
</html>