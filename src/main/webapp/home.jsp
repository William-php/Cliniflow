<%@page import="com.example.main.models.Perfil"%>
<%@page import="com.example.main.models.Consulta"%>
<%@page import="java.util.HashSet"%>

<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String nomeUsuario = usuarioLogado.getUsuario() != null ? usuarioLogado.getUsuario().getNomeUsuario() : "Usuário";
    
    @SuppressWarnings("unchecked")
    HashSet<Consulta> lista = (HashSet<Consulta>) request.getAttribute("consultasUsuarioLogado");

    StringBuilder datasConsultas = new StringBuilder("[");
    if (lista != null && !lista.isEmpty()) {
        for (Consulta c : lista) {
            // CORREÇÃO: Adicionado o toUpperCase() para não falhar na leitura do status
            if (c.getDataHoraInicioConsulta() != null && "AGENDADA".equalsIgnoreCase(c.getStatusConsulta() != null ? c.getStatusConsulta().name().toUpperCase() : "")) {
                String dataIso = c.getDataHoraInicioConsulta().toString().split("T")[0];
                datasConsultas.append("'").append(dataIso).append("',");
            }
        }
    }
    datasConsultas.append("]");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .calendar-box { text-align: center; margin-top: 16px; }
        .calendar-nav { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding: 0 10px; }
        .btn-mes { background: none; border: none; cursor: pointer; color: #12A388; font-size: 18px; padding: 5px 10px; transition: 0.2s; }
        .btn-mes:hover { background-color: #E6FFFA; border-radius: 8px; }
        .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 8px; text-align: center; }
        .calendar-header { font-weight: bold; color: #A0AEC0; font-size: 14px; padding-bottom: 8px; }
        .calendar-day { padding: 10px; font-size: 14px; color: #4A5568; border-radius: 50%; border: 2px solid transparent; }
        .calendar-day.muted { color: #CBD5E0; }
        .calendar-day.has-agenda { background-color: #E6FFFA; color: #12A388; border-color: #12A388; font-weight: bold; }
        .calendar-day.hoje { background-color: #2D3748; color: white; }

        .badge-agendada { background-color: #E6FFFA; color: #12A388; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge-espera { background-color: #FFFDF5; color: #DD6B20; border: 1px solid #FEEBC8; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge-cancelada { background-color: #FFF5F5; color: #E53E3E; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge-concluida { background-color: #F0FFF4; color: #22543D; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="home" class="nav-item active"><i class="fa-solid fa-house"></i> Início</a>
            <a href="minhas-consultas" class="nav-item"><i class="fa-solid fa-notes-medical"></i> Consultas</a>
            <a href="minha-lista-espera" class="nav-item"><i class="fa-solid fa-hourglass-start"></i> Lista(s) de Espera</a>
            <a href="editar-perfil" class="nav-item"><i class="fa-solid fa-user"></i> Perfil</a>
            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
        </ul>
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Tem certeza que deseja sair do sistema?');"><i class="fa-solid fa-arrow-right-from-bracket"></i> Sair</a>
    </aside>

    <main class="main-content">
        <% 
            String atualizado = request.getParameter("atualizado");
            String sucesso = request.getParameter("sucesso");
            
            if ("true".equals(atualizado)) {
        %>
            <div id="toast-alerta" class="toast-sucesso">
                <div class="toast-conteudo">
                    <i class="fa-solid fa-circle-check"></i> 
                    <span>Perfil atualizado com sucesso!</span>
                </div>
                <i class="fa-solid fa-xmark toast-fechar" onclick="fecharToast()"></i>
            </div>
            <script>
                setTimeout(fecharToast, 4000);
                function fecharToast() {
                    var toast = document.getElementById("toast-alerta");
                    if(toast) { toast.style.opacity = "0"; setTimeout(() => toast.remove(), 300); }
                }
            </script>
        <% } else if ("agendada".equals(sucesso)) { %>
            <div id="toast-alerta" class="toast-sucesso">
                <div class="toast-conteudo">
                    <i class="fa-solid fa-circle-check"></i> 
                    <span>Consulta agendada com sucesso!</span>
                </div>
                <i class="fa-solid fa-xmark toast-fechar" onclick="fecharToast()"></i>
            </div>
            <script>
                setTimeout(fecharToast, 4000);
                function fecharToast() {
                    var toast = document.getElementById("toast-alerta");
                    if(toast) { toast.style.opacity = "0"; setTimeout(() => toast.remove(), 300); }
                }
            </script>
        <% } else if ("espera".equals(sucesso)) { %>
            <div id="toast-alerta" class="toast-sucesso" style="background-color: #FFFDF5; color: #DD6B20; border-color: #DD6B20;">
                <div class="toast-conteudo">
                    <i class="fa-solid fa-hourglass-half"></i> 
                    <span>Você entrou na Lista de Espera desta consulta!</span>
                </div>
                <i class="fa-solid fa-xmark toast-fechar" style="color: #DD6B20;" onclick="fecharToast()"></i>
            </div>
            <script>
                setTimeout(fecharToast, 4000);
                function fecharToast() {
                    var toast = document.getElementById("toast-alerta");
                    if(toast) { toast.style.opacity = "0"; setTimeout(() => toast.remove(), 300); }
                }
            </script>
        <% } %>

        <header class="topbar">
            <div class="topbar-user">
                <p>Bem-vindo,</p>
                <h3><%= nomeUsuario %></h3>
            </div>
            <div class="next-appointment">
                <h4>Próxima consulta</h4>
                <h2><%= request.getAttribute("proxMedico") != null ? request.getAttribute("proxMedico") : "Nenhuma" %></h2>
                <p><%= request.getAttribute("proxData") != null ? request.getAttribute("proxData") : "--" %></p>
            </div>
            
            <!-- SINO DE NOTIFICAÇÕES -->
            <div class="notification-container" style="position: relative;">
                <div style="font-size: 24px; cursor: pointer; position: relative;" onclick="toggleNotificacoes()">
                    <i class="fa-regular fa-bell"></i>
                    <span id="notif-badge" style="display: none; position: absolute; top: -5px; right: -5px; background: #E53E3E; color: white; border-radius: 50%; width: 16px; height: 16px; font-size: 10px; justify-content: center; align-items: center; font-weight: bold; border: 2px solid #F7FAFC;">0</span>
                </div>

                <!-- MENU SUSPENSO -->
                <div id="notifDropdown" style="display: none; position: absolute; right: 0; top: 40px; width: 300px; background: #fff; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); border: 1px solid #E2E8F0; z-index: 1000; overflow: hidden;">
                    <div style="background: #F7FAFC; padding: 12px 16px; border-bottom: 1px solid #E2E8F0; display: flex; justify-content: space-between; align-items: center;">
                        <h4 style="margin: 0; font-size: 14px; color: #2D3748;">Notificações</h4>
                    </div>
                    <div id="notif-list" style="max-height: 300px; overflow-y: auto;">
                        <!-- O Javascript do localStorage preenche aqui -->
                    </div>
                </div>
            </div>
        </header>

        <div class="stats-grid">
            <div class="stat-card">
                <h2><%= request.getAttribute("consultasDia") != null ? request.getAttribute("consultasDia") : "0" %></h2>
                <p>Consultas no Dia</p>
            </div>
            <div class="stat-card">
                <h2><%= request.getAttribute("consultasMes") != null ? request.getAttribute("consultasMes") : "0" %></h2>
                <p>Consultas no Mês</p>
            </div>
            <div class="stat-card">
                <h2><%= request.getAttribute("totalConsultas") != null ? request.getAttribute("totalConsultas") : "0" %></h2>
                <p>Total Agendadas</p>
            </div>
        </div>

        <div class="content-area">
            
            <div class="content-card">
                <div class="header-consultas">
                    <h3 class="section-title" style="margin-bottom: 0;">Minhas Consultas</h3>
                    <button class="btn-agendar" onclick="window.location.href='agendamento'">
                        <i class="fa-solid fa-plus"></i> Agendar Consulta
                    </button>
                </div>

                <%
                    if (lista != null && !lista.isEmpty()) {
                        for (Consulta c : lista) {
                            String statusStr = c.getStatusConsulta() != null ? c.getStatusConsulta().name() : "PENDENTE";
                            
                            String classeBadge = "badge-agendada"; 
                            String textoBadge = "Agendada";
                            
                            if ("ESPERA".equalsIgnoreCase(statusStr) || "PENDENTE".equalsIgnoreCase(statusStr)) {
                                classeBadge = "badge-espera";
                                textoBadge = "Lista de Espera";
                            } else if ("CANCELADA".equalsIgnoreCase(statusStr)) {
                                classeBadge = "badge-cancelada";
                                textoBadge = "Cancelada";
                            } else if ("CONCLUIDA".equalsIgnoreCase(statusStr) || "REALIZADA".equalsIgnoreCase(statusStr)) {
                                classeBadge = "badge-concluida";
                                textoBadge = "Concluída";
                            }
                            
                            String nomeMedico = "Dr(a). Indefinido";
                            if (c.getMedicoConsulta() != null && c.getMedicoConsulta().getUsuario() != null) {
                                nomeMedico = "Dr(a). " + c.getMedicoConsulta().getUsuario().getNomeUsuario() + " " + c.getMedicoConsulta().getUsuario().getSobrenomeUsuario();
                            }
                %>
                        <div class="card-consulta">
                            <h4 class="medico-nome"><%= nomeMedico %></h4>
                            <p class="especialidade">Consulta Médica</p>
                            <div class="rodape-consulta">
                                <span class="data"><%= c.getDataHoraInicioConsulta() != null ? c.getDataHoraInicioConsulta().toString().replace("T", " às ") : "" %></span>
                                <span class="<%= classeBadge %>"><%= textoBadge %></span>
                            </div>
                        </div>
                <%
                        } 
                    } else {
                %>
                    <p style="color: #A0AEC0; font-size: 14px; margin-top: 16px;">Você não possui consultas registradas.</p>
                <%
                    } 
                %>
            </div>

            <div class="content-card">
                <h3 class="section-title">Calendário</h3>
                
                <div class="calendar-box">
                    <div class="calendar-nav">
                        <button type="button" class="btn-mes" onclick="mudarMes(-1)"><i class="fa-solid fa-chevron-left"></i></button>
                        <h4 id="mes-ano-display" style="color: #2D3748; font-weight: bold; margin: 0; font-size: 18px;">Carregando...</h4>
                        <button type="button" class="btn-mes" onclick="mudarMes(1)"><i class="fa-solid fa-chevron-right"></i></button>
                    </div>
                    
                    <div class="calendar-grid" id="calendario-dias">
                    </div>
                    
                    <div style="display: flex; justify-content: center; gap: 16px; margin-top: 24px; font-size: 12px; color: #718096;">
                        <div style="display: flex; align-items: center; gap: 6px;">
                            <div style="width: 12px; height: 12px; border-radius: 50%; background-color: #E6FFFA; border: 2px solid #12A388;"></div>
                            <span>Com Consulta</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 6px;">
                            <div style="width: 12px; height: 12px; border-radius: 50%; background-color: #2D3748;"></div>
                            <span>Hoje</span>
                        </div>
                    </div>
                </div>

            </div>
            
        </div>
    </main>
</div>

<script>
    const datasComConsulta = <%= datasConsultas.toString() %>;
    
    let dataSistema = new Date();
    let mesAtual = dataSistema.getMonth();
    let anoAtual = dataSistema.getFullYear();

    const nomesMeses = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];

    function renderizarCalendario(mes, ano) {
        document.getElementById("mes-ano-display").innerText = nomesMeses[mes] + " " + ano;
        const grid = document.getElementById("calendario-dias");
        
        let cabecalho = '<div class="calendar-header">D</div><div class="calendar-header">S</div><div class="calendar-header">T</div><div class="calendar-header">Q</div><div class="calendar-header">Q</div><div class="calendar-header">S</div><div class="calendar-header">S</div>';
        let diasHtml = "";
        
        let primeiroDiaDoMes = new Date(ano, mes, 1).getDay(); 
        let qtdDiasNoMes = new Date(ano, mes + 1, 0).getDate();
        
        for(let i = 0; i < primeiroDiaDoMes; i++) {
            diasHtml += '<div class="calendar-day muted"></div>';
        }
        
        for(let dia = 1; dia <= qtdDiasNoMes; dia++) {
            let dataString = ano + "-" + String(mes + 1).padStart(2, '0') + "-" + String(dia).padStart(2, '0');
            let classeExtra = "";
            let titleText = "";

            if (dia === dataSistema.getDate() && mes === dataSistema.getMonth() && ano === dataSistema.getFullYear()) {
                classeExtra += " hoje";
            }
            
            if (datasComConsulta.includes(dataString)) {
                classeExtra += " has-agenda";
                titleText = "Consulta agendada neste dia!";
            }
            
            diasHtml += '<div class="calendar-day' + classeExtra + '" title="' + titleText + '">' + dia + '</div>';
        }
        
        grid.innerHTML = cabecalho + diasHtml;
    }

    function mudarMes(direcao) {
        mesAtual += direcao;
        if (mesAtual > 11) {
            mesAtual = 0;
            anoAtual++;
        } else if (mesAtual < 0) {
            mesAtual = 11;
            anoAtual--;
        }
        renderizarCalendario(mesAtual, anoAtual);
    }

    // ==========================================
    // SISTEMA DE NOTIFICAÇÕES (LOCALSTORAGE)
    // Funciona como o AsyncStorage do Mobile!
    // ==========================================
    const idUsuarioStr = '<%= usuarioLogado.getUsuario().getIdUsuario() %>';
    const storageKey = 'cliniflow_notif_' + idUsuarioStr;

    function getNotificacoes() {
        return JSON.parse(localStorage.getItem(storageKey)) || [];
    }

    function salvarNotificacoes(notifs) {
        localStorage.setItem(storageKey, JSON.stringify(notifs));
    }

    function adicionarNotificacao(titulo, mensagem) {
        const notifs = getNotificacoes();
        notifs.unshift({ id: Date.now(), titulo, mensagem, lida: false });
        salvarNotificacoes(notifs);
        renderizarNotificacoes();
    }

    function marcarLidaEApagar(id) {
        let notifs = getNotificacoes();
        notifs = notifs.filter(n => n.id !== id);
        salvarNotificacoes(notifs);
        renderizarNotificacoes();
    }

    function renderizarNotificacoes() {
        const notifs = getNotificacoes();
        const badge = document.getElementById('notif-badge');
        const list = document.getElementById('notif-list');
        
        if (notifs.length > 0) {
            badge.style.display = 'flex';
            badge.innerText = notifs.length;
            list.innerHTML = notifs.map(n => `
                <div style="padding: 12px 16px; border-bottom: 1px solid #EDF2F7; cursor: pointer;" onclick="marcarLidaEApagar(${n.id})">
                    <h5 style="margin: 0 0 4px 0; font-size: 13px; color: #2D3748;">${n.titulo}</h5>
                    <p style="margin: 0; font-size: 12px; color: #718096; line-height: 1.4;">${n.mensagem}</p>
                </div>
            `).join('');
        } else {
            badge.style.display = 'none';
            list.innerHTML = '<div style="padding: 24px; text-align: center; color: #A0AEC0; font-size: 13px;">Nenhuma notificação.</div>';
        }
    }

    function toggleNotificacoes() {
        const menu = document.getElementById('notifDropdown');
        menu.style.display = menu.style.display === 'block' ? 'none' : 'block';
    }

    // Fecha o modal se clicar fora
    document.addEventListener('click', function(event) {
        const container = document.querySelector('.notification-container');
        const menu = document.getElementById('notifDropdown');
        if (!container.contains(event.target) && menu.style.display === 'block') {
            menu.style.display = 'none';
        }
    });

    window.onload = function() {
        // CORREÇÃO: Garante que o calendário seja desenhado ao abrir a página
        renderizarCalendario(mesAtual, anoAtual);
        
        // Verifica a URL para criar a notificação automaticamente!
        const urlParams = new URLSearchParams(window.location.search);
        const sucesso = urlParams.get('sucesso');
        
        // Usamos sessionStorage para garantir que a notificação só seja gerada 1x por agendamento
        const handled = sessionStorage.getItem('notif_gerada_' + sucesso);
        
        if (sucesso && !handled) {
            
            // 1. Tentar buscar os dados detalhados da consulta no localStorage
            let dadosConsulta = null;
            const savedData = localStorage.getItem('dadosUltimaConsulta');
            
            if (savedData) {
                try {
                    dadosConsulta = JSON.parse(savedData);
                } catch(e) {
                    console.error("Erro ao ler localStorage", e);
                }
            }

            let tituloNotificacao = "";
            let mensagemNotificacao = "";

            // 2. Montar as mensagens dinamicamente
            if (sucesso === 'agendada') {
                tituloNotificacao = 'Consulta Confirmada!';
                
                if (dadosConsulta) {
                    // Formata "2026-08-25" para "25/08/2026"
                    const partesData = dadosConsulta.data.split('-');
                    const dataFormatada = partesData.length === 3 ? `${partesData[2]}/${partesData[1]}/${partesData[0]}` : dadosConsulta.data;
                    
                    // Pega apenas o horário caso venha algum texto extra (ex: "14:00 - LIVRE")
                    const horarioLimpo = dadosConsulta.horarioRaw.split(' ')[0];

                    mensagemNotificacao = `Sua consulta com o(a) <b>${dadosConsulta.medico}</b> (${dadosConsulta.especialidade}) foi agendada para o dia <b>${dataFormatada}</b> às <b>${horarioLimpo}</b>.`;
                } else {
                    mensagemNotificacao = 'Você tem um novo agendamento marcado. Chegue com 15min de antecedência.';
                }
                
            } else if (sucesso === 'espera') {
                tituloNotificacao = 'Lista de Espera';
                
                if (dadosConsulta) {
                    const partesData = dadosConsulta.data.split('-');
                    const dataFormatada = partesData.length === 3 ? `${partesData[2]}/${partesData[1]}/${partesData[0]}` : dadosConsulta.data;
                    const horarioLimpo = dadosConsulta.horarioRaw.split(' ')[0];

                    mensagemNotificacao = `Você entrou na fila de espera para o(a) <b>${dadosConsulta.medico}</b> no dia <b>${dataFormatada}</b> às <b>${horarioLimpo}</b>. Avisaremos se liberar vaga!`;
                } else {
                    mensagemNotificacao = 'Você entrou na fila. Te avisaremos caso o sistema libere uma vaga pra você!';
                }
            }
            
            // 3. Dispara a notificação e salva a flag na sessão
            if (tituloNotificacao) {
                adicionarNotificacao(tituloNotificacao, mensagemNotificacao);
                sessionStorage.setItem('notif_gerada_' + sucesso, 'true');
                
                // Limpa o localStorage para que agendamentos futuros não usem dados velhos
                localStorage.removeItem('dadosUltimaConsulta');
            }
        }
        
        renderizarNotificacoes();
    };
</script>

</body>
</html>