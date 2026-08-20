<%@page import="com.example.main.models.Perfil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String nomeMedico = usuarioLogado.getUsuario() != null ? usuarioLogado.getUsuario().getNomeUsuario() + " " + usuarioLogado.getUsuario().getSobrenomeUsuario() : "Médico";
    
    String proxPaciente = (String) request.getAttribute("proxPaciente");
    if (proxPaciente == null) proxPaciente = "Nenhum paciente";
    
    String proxHorario = (String) request.getAttribute("proxHorario");
    if (proxHorario == null) proxHorario = "--";
    
    Integer consultasDia = (Integer) request.getAttribute("consultasDia");
    if (consultasDia == null) consultasDia = 0;
    
    Integer consultasMes = (Integer) request.getAttribute("consultasMes");
    if (consultasMes == null) consultasMes = 0;
    
    Integer concluidasMes = (Integer) request.getAttribute("concluidasMes");
    if (concluidasMes == null) concluidasMes = 0;
    
    String datasComAgenda = (String) request.getAttribute("datasComAgenda"); 
    if (datasComAgenda == null || datasComAgenda.trim().isEmpty()) datasComAgenda = "[]";

    String dadosGraficoAno = (String) request.getAttribute("dadosGraficoAno");
    if (dadosGraficoAno == null || dadosGraficoAno.trim().isEmpty()) dadosGraficoAno = "[0,0,0,0,0,0,0,0,0,0,0,0]";
%>
<!DOCTYPE html>
<html lang="pt-BR">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>CliniFlow - Portal do Médico</title>
	    <link rel="stylesheet" href="css/style.css">
	    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
	    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
	</head>
	<body class="home-body">
		
		<div class="dashboard-layout">
		    
		    <aside class="sidebar">
		        <div class="sidebar-logo">Clini<span>Flow</span></div>
		        <ul class="nav-menu">
		            <a href="medico-home" class="nav-item active"><i class="fa-solid fa-house"></i> Início</a>
		            <a href="medico-agenda" class="nav-item"><i class="fa-solid fa-calendar-days"></i> Minha Agenda</a>
		            <a href="editar-perfil" class="nav-item"><i class="fa-solid fa-user-doctor"></i> Perfil</a>
		            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
		        </ul>
		        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Tem certeza que deseja sair do sistema?');">
		            <i class="fa-solid fa-arrow-right-from-bracket"></i> Sair
		        </a>
		    </aside>
		
		    <main class="main-content">
		        
		        <header class="topbar">
		            <div class="topbar-user">
		                <p>Bem-vindo,</p>
		                <h3>Dr(a). <%= nomeMedico %></h3>
		            </div>
		            <div class="next-appointment">
		                <h4>Próximo paciente</h4>
		                <h2><%= proxPaciente %></h2>
		                <p><%= proxHorario %></p>
		            </div>
		            
		            <!-- SINO DE NOTIFICAÇÕES MÉDICO -->
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
		                <h2><%= consultasDia %></h2>
		                <p>Consultas no Dia</p>
		            </div>
		            <div class="stat-card">
		                <h2><%= consultasMes %></h2>
		                <p>Consultas no Mês</p>
		            </div>
		            <div class="stat-card">
		                <h2><%= concluidasMes %></h2>
		                <p>Realizadas no Mês</p>
		            </div>
		        </div>
		
		        <div style="text-align: center; margin-bottom: 24px; padding: 0 40px;">
		            <button class="btn-agenda-preto" onclick="window.location.href='medico-agenda'">
		                <i class="fa-solid fa-calendar-days"></i> Minha Agenda Completa
		            </button>
		        </div>
		
		        <div class="content-area" style="padding-top: 0;">
		            
		            <div class="content-card">
		                <h3 class="section-title">Atendimentos no Ano</h3>
		                <div style="position: relative; flex-grow: 1; width: 100%; min-height: 200px; margin-top: 16px;">
		    				<canvas id="atendimentosChart"></canvas>
						</div>
		            </div>
		
		            <div class="content-card">
		                <h3 class="section-title">Calendário</h3>
		                
		                <div class="calendar-box">
		                    <div class="calendar-nav">
		                        <button type="button" class="btn-mes" onclick="mudarMes(-1)"><i class="fa-solid fa-chevron-left"></i></button>
		                        <h4 id="mes-ano-display" style="color: #2D3748; font-weight: bold; margin: 0; font-size: 15px;">Carregando...</h4>
		                        <button type="button" class="btn-mes" onclick="mudarMes(1)"><i class="fa-solid fa-chevron-right"></i></button>
		                    </div>
		                    
		                    <div class="calendar-grid" id="calendario-dias">
		                    </div>
		                    
		                    <div style="display: flex; justify-content: center; gap: 16px; margin-top: 16px; font-size: 11px; color: #718096;">
		                        <div style="display: flex; align-items: center; gap: 6px;">
		                            <div style="width: 10px; height: 10px; border-radius: 50%; background-color: #E6FFFA; border: 2px solid #12A388;"></div>
		                            <span>Com Agenda</span>
		                        </div>
		                        <div style="display: flex; align-items: center; gap: 6px;">
		                            <div style="width: 10px; height: 10px; border-radius: 50%; background-color: #2D3748;"></div>
		                            <span>Hoje</span>
		                        </div>
		                    </div>
		                </div>
		
		            </div>
		            
		        </div>
		    </main>
		</div>
		
		<script>
		    const dadosGraficoAno = <%= dadosGraficoAno %>;
		
		    const ctx = document.getElementById('atendimentosChart').getContext('2d');
		    const atendimentosChart = new Chart(ctx, {
		        type: 'bar',
		        data: {
		            labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
		            datasets: [{
		                label: 'Atendimentos',
		                data: dadosGraficoAno,
		                backgroundColor: '#12A388',
		                hoverBackgroundColor: '#0e826c',
		                borderRadius: 4,
		                barPercentage: 0.6
		            }]
		        },
		        options: {
		            responsive: true,
		            maintainAspectRatio: false, 
		            plugins: {
		                legend: { display: false },
		                tooltip: {
		                    backgroundColor: '#2D3748',
		                    padding: 8,
		                    titleFont: { size: 12 },
		                    bodyFont: { size: 12, weight: 'bold' },
		                    displayColors: false
		                }
		            },
		            scales: {
		                y: {
		                    beginAtZero: true,
		                    grid: { color: '#EDF2F7', drawBorder: false },
		                    ticks: { color: '#A0AEC0', stepSize: 5 }
		                },
		                x: {
		                    grid: { display: false, drawBorder: false },
		                    ticks: { color: '#718096', font: { size: 11 } }
		                }
		            }
		        }
		    });
		
		    const datasComAgenda = <%= datasComAgenda %>;
		    
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
		            
		            if (datasComAgenda.includes(dataString)) {
		                classeExtra += " has-agenda";
		                titleText = "Você possui atendimentos agendados neste dia!";
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
		
		    // sistema de notificacao (LOCALSTORAGE)
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
		
		    document.addEventListener('click', function(event) {
		        const container = document.querySelector('.notification-container');
		        const menu = document.getElementById('notifDropdown');
		        if (!container.contains(event.target) && menu.style.display === 'block') {
		            menu.style.display = 'none';
		        }
		    });
		
		    window.onload = function() {
		        renderizarCalendario(mesAtual, anoAtual);
		        
		        const urlParams = new URLSearchParams(window.location.search);
		        const sucesso = urlParams.get('sucesso');
		        
		        const handled = sessionStorage.getItem('notif_gerada_' + sucesso);
		        if (sucesso && !handled) {
		            if (sucesso === 'agendada') {
		                adicionarNotificacao('Novo Agendamento', 'Um novo paciente marcou consulta na sua agenda.');
		            } else if (sucesso === 'cancelada') {
		                adicionarNotificacao('Consulta Cancelada', 'Um paciente desmarcou a consulta.');
		            } else if (sucesso === 'alocada') {
		                adicionarNotificacao('Fila de Espera Movida', 'A recepção alocou um paciente da fila na sua agenda.');
		            }
		            sessionStorage.setItem('notif_gerada_' + sucesso, 'true');
		        }
		        
		        renderizarNotificacoes();
		    };
		</script>
		
	</body>
</html>