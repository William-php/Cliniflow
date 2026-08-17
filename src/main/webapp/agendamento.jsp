<%@page import="java.util.HashSet"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.Collection, com.example.main.models.Perfil, com.example.main.models.Especialidade" %>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String nomeUsuario = usuarioLogado.getUsuario() != null ? usuarioLogado.getUsuario().getNomeUsuario() : "Usuário";
%>
<!DOCTYPE html>
<html lang="pt-BR">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>CliniFlow - Novo Agendamento</title>
	    <link rel="stylesheet" href="css/style.css">
	    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
	</head>
	<body class="home-body">
	
	<div class="dashboard-layout">
	    
	    <!-- BARRA LATERAL ATUALIZADA E SINCRONIZADA COM A HOME -->
	    <aside class="sidebar">
	        <div class="sidebar-logo">Clini<span>Flow</span></div>
	        <ul class="nav-menu">
	            <a href="home" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
	            <a href="minhas-consultas" class="nav-item"><i class="fa-solid fa-notes-medical"></i> Consultas</a>
	            <a href="minha-lista-espera" class="nav-item"><i class="fa-solid fa-hourglass-start"></i> Lista(s) de Espera</a>
	            <a href="/cliniflow/editar-perfil.jsp" class="nav-item"><i class="fa-solid fa-user"></i> Perfil</a>
	            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
	        </ul>
	        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;"><i class="fa-solid fa-arrow-right-from-bracket"></i> Sair</a>
	    </aside>
	
	    <!-- ÁREA PRINCIPAL -->
	    <main class="main-content">
	        
	        <header class="topbar">
	            <div class="topbar-user">
	                <p>Novo Agendamento,</p>
	                <h3><%= nomeUsuario %></h3>
	            </div>
	        </header>
	
	        <div class="content-area" style="grid-template-columns: 1fr; padding-top: 32px;">
	            <div class="content-card">
	                <h3 class="section-title" style="font-size: 20px; margin-bottom: 24px;">Agendar Consulta</h3>
	
	                <form action="agendamento" method="POST" id="formAgendamento">
	                    
	                    <!-- Campos Ocultos para enviar pro Java no POST -->
	                    <input type="hidden" name="data_escolhida" id="data_escolhida">
	                    <input type="hidden" name="horario_escolhido" id="horario_escolhido">
	
	                    <div class="input-group" style="margin-bottom: 0;">
	                        <label style="font-size: 12px; color: #A0AEC0; margin-bottom: 4px; display: block;">Especialidade</label>
	                        <select name="id_especialidade" id="especialidade" class="select-custom" onchange="buscarMedicos()" required>
	                            <option value="" disabled selected>Selecione uma especialidade</option>
	                            <%
	                                @SuppressWarnings("unchecked")
	                                HashSet<Especialidade> listaEspecialidades = (HashSet<Especialidade>) request.getAttribute("especialidades");
	                                if (listaEspecialidades != null) {
	                                    for (Especialidade esp : listaEspecialidades) {
	                            %>
	                                    <option value="<%= esp.getIdEspecialidade() %>"><%= esp.getTipoEspecialidade().name() %></option>
	                            <%
	                                    }
	                                }
	                            %>
	                        </select>
	                    </div>
	
	                    <div class="input-group" style="margin-bottom: 0;">
	                        <label style="font-size: 12px; color: #A0AEC0; margin-bottom: 4px; display: block;">Médico</label>
	                        <select name="id_medico" id="medico" class="select-custom" onchange="buscarDatas()" required disabled>
	                            <option value="" disabled selected>Selecione primeiro a especialidade...</option>
	                        </select>
	                    </div>
	
	                    <div class="agendamento-grid">
	                        
	                        <!-- Calendário Dinâmico -->
	                        <div class="calendar-box">
	                            <div class="calendar-nav">
	                                <button type="button" class="btn-mes" onclick="mudarMes(-1)"><i class="fa-solid fa-chevron-left"></i></button>
	                                <h4 id="mes-atual" style="color: #2D3748; font-weight: bold; margin: 0; font-size: 18px;">Aguardando...</h4>
	                                <button type="button" class="btn-mes" onclick="mudarMes(1)"><i class="fa-solid fa-chevron-right"></i></button>
	                            </div>
	                            <div class="calendar-grid" id="calendario-dias">
	                                <!-- Preenchido pelo JS -->
	                            </div>
	                        </div>
	
	                        <!-- Horários Dinâmicos -->
	                        <div class="slots-container">
	                            <div>
	                                <h4 id="titulo-horarios" style="color: #2D3748; font-weight: bold; margin-bottom: 16px;">Selecione um dia</h4>
	                                <div class="slots-grid" id="grade-horarios">
	                                    <!-- Preenchido pelo JS -->
	                                </div>
	                            </div>
	                            
	                            <button type="submit" class="btn-main" id="btn-submit" style="margin-bottom: 0;" disabled>Agendar</button>
	                        </div>
	                    </div>
	                </form>
	            </div>
	        </div>
	    </main>
	</div>
	
	<!-- SCRIPTS PARA INTEGRAÇÃO COM O BACKEND -->
	<script>
	    // Variáveis Globais de Controle do Calendário
	    let dataSistema = new Date();
	    let mesAtual = dataSistema.getMonth();
	    let anoAtual = dataSistema.getFullYear();
	    const nomesMeses = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];
	    
	    // Guarda os dias que o médico atende para não perder ao trocar de mês
	    let diasDisponiveisGlobal = [];
	
	    // 1. Busca os Médicos da Especialidade
	    function buscarMedicos() {
	        var especialidadeId = document.getElementById("especialidade").value;
	        var selectMedico = document.getElementById("medico");
	        limparTudo();
	
	        selectMedico.innerHTML = '<option value="">Buscando médicos...</option>';
	        selectMedico.disabled = true;
	
	        fetch('agendamento?acao=buscarMedicos&id_especialidade=' + especialidadeId)
	            .then(response => response.text())
	            .then(html => {
	                selectMedico.innerHTML = html;
	                selectMedico.disabled = false;
	            });
	    }
	
	    // 2. Busca as Datas do Médico
	    function buscarDatas() {
	        var medicoId = document.getElementById("medico").value;
	        if(!medicoId) { limparTudo(); return; }
	
	        document.getElementById("mes-atual").innerText = "Buscando agenda...";
	        
	        fetch('agendamento?acao=buscarDatas&id_medico=' + medicoId)
	            .then(response => response.json())
	            .then(datasDoBanco => {
	                diasDisponiveisGlobal = datasDoBanco; 
	                
	                mesAtual = dataSistema.getMonth();
	                anoAtual = dataSistema.getFullYear();
	                
	                desenharCalendario(mesAtual, anoAtual);
	            });
	    }
	
	    // Função Auxiliar: Desenhar o Grid do Calendário
	    function desenharCalendario(mes, ano) {
	        document.getElementById("mes-atual").innerText = nomesMeses[mes] + " " + ano;
	        var grid = document.getElementById("calendario-dias");
	        
	        var cabecalho = '<div class="calendar-header">D</div><div class="calendar-header">S</div><div class="calendar-header">T</div><div class="calendar-header">Q</div><div class="calendar-header">Q</div><div class="calendar-header">S</div><div class="calendar-header">S</div>';
	        var diasHtml = "";
	        
	        let primeiroDiaDoMes = new Date(ano, mes, 1).getDay(); 
	        let qtdDiasNoMes = new Date(ano, mes + 1, 0).getDate();
	        
	        for(let i=0; i < primeiroDiaDoMes; i++) {
	            diasHtml += '<div class="calendar-day muted"></div>'; 
	        }
	        
	        for(let dia = 1; dia <= qtdDiasNoMes; dia++) {
	            let mesFormatado = String(mes + 1).padStart(2, '0');
	            let diaFormatado = String(dia).padStart(2, '0');
	            let dataString = ano + "-" + mesFormatado + "-" + diaFormatado;
	            
	            if(diasDisponiveisGlobal.includes(dataString)) {
	                diasHtml += '<div class="calendar-day has-agenda" onclick="selecionarDia(' + dia + ', ' + (mes + 1) + ', ' + ano + ', this)">' + dia + '</div>';
	            } else {
	                diasHtml += '<div class="calendar-day muted">' + dia + '</div>';
	            }
	        }
	        grid.innerHTML = cabecalho + diasHtml;
	    }
	
	    // Função para mudar o mês usando os botões
	    function mudarMes(direcao) {
	        if (document.getElementById("medico").value === "" || document.getElementById("medico").disabled) {
	            return;
	        }
	
	        mesAtual += direcao;
	        if (mesAtual > 11) {
	            mesAtual = 0;
	            anoAtual++;
	        } else if (mesAtual < 0) {
	            mesAtual = 11;
	            anoAtual--;
	        }
	        desenharCalendario(mesAtual, anoAtual);
	    }
	
	    // 3. Ao Clicar em um Dia, busca os Horários
	    function selecionarDia(dia, mes, ano, elemento) {
	        var dataFormatada = ano + "-" + mes.toString().padStart(2, '0') + "-" + dia.toString().padStart(2, '0');
	        document.getElementById("data_escolhida").value = dataFormatada;
	        
	        document.querySelectorAll('.calendar-day').forEach(d => d.classList.remove('selected'));
	        elemento.classList.add('selected');
	
	        var medicoId = document.getElementById("medico").value;
	        document.getElementById("titulo-horarios").innerText = "Buscando horários...";
	        document.getElementById("grade-horarios").innerHTML = "";
	        document.getElementById("btn-submit").disabled = true;
	
	        fetch('agendamento?acao=buscarHorarios&id_medico=' + medicoId + '&data=' + dataFormatada)
	            .then(response => response.text())
	            .then(html => {
	                document.getElementById("titulo-horarios").innerText = "Horários — Dia " + String(dia).padStart(2, '0') + "/" + String(mes).padStart(2, '0');
	                document.getElementById("grade-horarios").innerHTML = html;
	            });
	    }
	
	    // 4. Ao Clicar no Horário, libera o botão Agendar
	    function selecionarHorario(elemento, horario) {
	        document.getElementById("horario_escolhido").value = horario;
	        document.querySelectorAll('.slot-btn').forEach(b => b.classList.remove('active'));
	        elemento.classList.add('active');
	        document.getElementById("btn-submit").disabled = false;
	    }
	
	    function limparTudo() {
	        document.getElementById("calendario-dias").innerHTML = "";
	        document.getElementById("mes-atual").innerText = "Aguardando Seleção...";
	        document.getElementById("grade-horarios").innerHTML = "";
	        document.getElementById("titulo-horarios").innerText = "Selecione um dia";
	        document.getElementById("btn-submit").disabled = true;
	        diasDisponiveisGlobal = [];
	    }
	</script>
	
	</body>
</html>