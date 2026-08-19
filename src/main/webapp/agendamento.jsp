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
    
   <style>
        /* ESTILIZAÇÃO DOS DIAS NO CALENDÁRIO (Herdando formato do style.css) */
        .calendar-day.has-agenda { 
            background-color: #E6FFFA !important; 
            color: #12A388 !important; 
            font-weight: bold; 
            border-color: #B2F5EA !important;
            cursor: pointer; 
        }
        
        /* Dia com todos os horários ocupados (Vermelho) */
        .calendar-day.day-lotado { 
            background-color: #FFF5F5 !important; 
            color: #E53E3E !important; 
            font-weight: bold; 
            border-color: #FEB2B2 !important;
            cursor: pointer; 
        }

        .calendar-day.selected { 
            background-color: #12A388 !important; 
            color: #FFFFFF !important; 
            border-color: #12A388 !important; 
        }
        .calendar-day.day-lotado.selected { 
            background-color: #E53E3E !important; 
            color: #FFFFFF !important; 
            border-color: #E53E3E !important; 
        }

        /* ESTILIZAÇÃO DOS SLOTS DE HORÁRIOS (Somente cores e comportamento) */
        .slot-btn { cursor: pointer; transition: 0.2s; }
        .slot-btn:hover { border-color: #12A388; color: #12A388; }
        .slot-btn.active { background-color: #12A388 !important; color: white !important; border-color: #12A388 !important; }

        /* Horário Ocupado (Vermelho) */
        .slot-btn.occupied { 
            background-color: #FFF5F5 !important; 
            color: #E53E3E !important; 
            border-color: #FEB2B2 !important; 
        }
        .slot-btn.occupied:hover { background-color: #FED7D7 !important; }
        .slot-btn.occupied.active { 
            background-color: #E53E3E !important; 
            color: #FFFFFF !important; 
            border-color: #E53E3E !important; 
        }

        /* BOTÃO PRINCIPAL DINÂMICO */
        .btn-espera-laranja {
            background-color: #DD6B20 !important;
            border-color: #DD6B20 !important;
            color: #FFFFFF !important;
        }
        .btn-espera-laranja:hover {
            background-color: #C05621 !important;
        }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="home" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
            <a href="minhas-consultas" class="nav-item"><i class="fa-solid fa-notes-medical"></i> Consultas</a>
            <a href="minha-lista-espera" class="nav-item"><i class="fa-solid fa-hourglass-start"></i> Lista(s) de Espera</a>
            <a href="editar-perfil" class="nav-item"><i class="fa-solid fa-user"></i> Perfil</a>
            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
        </ul>
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Deseja realmente sair?');"><i class="fa-solid fa-arrow-right-from-bracket"></i> Sair</a>
    </aside>

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
                    <input type="hidden" name="data_escolhida" id="data_escolhida">
                    <input type="hidden" name="horario_escolhido" id="horario_escolhido">
                    
                    <!-- ========================================== -->
                    <!-- CAMPO MOCADO INVISÍVEL (Enviado no POST) -->
                    <input type="hidden" name="campo_mocado_exemplo" value="VALOR_MOCADO_AQUI">
                    <!-- ========================================== -->

                    <!-- ========================================== -->
                    <!-- CAMPO MOCADO VISÍVEL (Opcional - Exemplo: Tipo de Consulta) -->
                    <div class="input-group" style="margin-bottom: 16px;">
                        <label style="font-size: 12px; color: #A0AEC0; margin-bottom: 4px; display: block;">Tipo de Atendimento</label>
                        <input type="text" class="select-custom" name="tipo_atendimento_mocado" value="Presencial" readonly style="background-color: #F7FAFC; color: #718096; cursor: not-allowed; border: 1px solid #E2E8F0; width: 100%; padding: 10px; border-radius: 8px;">
                    </div>
                    <!-- ========================================== -->

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
                        
                        <!-- Calendário -->
                        <div class="calendar-box">
                            <div class="calendar-nav">
                                <button type="button" class="btn-mes" onclick="mudarMes(-1)"><i class="fa-solid fa-chevron-left"></i></button>
                                <h4 id="mes-atual" style="color: #2D3748; font-weight: bold; margin: 0; font-size: 18px;">Aguardando...</h4>
                                <button type="button" class="btn-mes" onclick="mudarMes(1)"><i class="fa-solid fa-chevron-right"></i></button>
                            </div>
                            <div class="calendar-grid" id="calendario-dias">
                            </div>
                        </div>

                        <!-- Horários -->
                        <div class="slots-container">
                            <div>
                                <h4 id="titulo-horarios" style="color: #2D3748; font-weight: bold; margin-bottom: 16px;">Selecione um dia</h4>
                                <div class="slots-grid" id="grade-horarios">
                                </div>
                                
                                <!-- LEGENDA DOS HORÁRIOS (Oculta até carregar os horários) -->
                                <!-- LEGENDA DOS HORÁRIOS (Com espaçamento ajustado) -->
								<div id="legenda-horarios" style="display: none; justify-content: center; gap: 16px; margin-top: 16px; margin-bottom: 40px; font-size: 12px; color: #718096;">
								    <div style="display: flex; align-items: center; gap: 6px;">
								        <div style="width: 12px; height: 12px; border-radius: 4px; background-color: #F7FAFC; border: 1px solid #12A388;"></div>
								        <span>Livre</span>
								    </div>
								    <div style="display: flex; align-items: center; gap: 6px;">
								        <div style="width: 12px; height: 12px; border-radius: 4px; background-color: #FFF5F5; border: 1px solid #FC8181;"></div>
								        <span>Ocupado (Espera)</span>
								    </div>
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

<script>
    let dataSistema = new Date();
    let mesAtual = dataSistema.getMonth();
    let anoAtual = dataSistema.getFullYear();
    const nomesMeses = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];
    
    // Armazena a lista de objetos [{data: "2026-08-20", lotado: false}, ...]
    let agendaDatasGlobal = [];

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

    function buscarDatas() {
        var medicoId = document.getElementById("medico").value;
        if(!medicoId) { limparTudo(); return; }

        document.getElementById("mes-atual").innerText = "Buscando agenda...";
        
        fetch('agendamento?acao=buscarDatas&id_medico=' + medicoId)
            .then(response => response.json())
            .then(datasDoBanco => {
                agendaDatasGlobal = datasDoBanco; 
                mesAtual = dataSistema.getMonth();
                anoAtual = dataSistema.getFullYear();
                desenharCalendario(mesAtual, anoAtual);
            });
    }

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
            
            let diaEncontrado = agendaDatasGlobal.find(item => item.data === dataString);
            
            if(diaEncontrado) {
                if(diaEncontrado.lotado) {
                    diasHtml += '<div class="calendar-day day-lotado" onclick="selecionarDia(' + dia + ', ' + (mes + 1) + ', ' + ano + ', this)">' + dia + '</div>';
                } else {
                    diasHtml += '<div class="calendar-day has-agenda" onclick="selecionarDia(' + dia + ', ' + (mes + 1) + ', ' + ano + ', this)">' + dia + '</div>';
                }
            } else {
                diasHtml += '<div class="calendar-day muted">' + dia + '</div>';
            }
        }
        grid.innerHTML = cabecalho + diasHtml;
    }

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

    function selecionarDia(dia, mes, ano, elemento) {
        var dataFormatada = ano + "-" + mes.toString().padStart(2, '0') + "-" + dia.toString().padStart(2, '0');
        document.getElementById("data_escolhida").value = dataFormatada;
        
        document.querySelectorAll('.calendar-day').forEach(d => d.classList.remove('selected'));
        elemento.classList.add('selected');

        var medicoId = document.getElementById("medico").value;
        document.getElementById("titulo-horarios").innerText = "Buscando horários...";
        document.getElementById("grade-horarios").innerHTML = "";
        document.getElementById("legenda-horarios").style.display = "none";
        
        var btnSubmit = document.getElementById("btn-submit");
        btnSubmit.disabled = true;
        btnSubmit.innerText = "Agendar";
        btnSubmit.classList.remove("btn-espera-laranja");

        fetch('agendamento?acao=buscarHorarios&id_medico=' + medicoId + '&data=' + dataFormatada)
            .then(response => response.text())
            .then(html => {
                document.getElementById("titulo-horarios").innerText = "Horários — Dia " + String(dia).padStart(2, '0') + "/" + String(mes).padStart(2, '0');
                document.getElementById("grade-horarios").innerHTML = html;
                document.getElementById("legenda-horarios").style.display = "flex"; // Mostra a legenda ao carregar
            });
    }

    function selecionarHorario(elemento, horarioCompleto) {
        document.getElementById("horario_escolhido").value = horarioCompleto;
        document.querySelectorAll('.slot-btn').forEach(b => b.classList.remove('active'));
        elemento.classList.add('active');
        
        var btnSubmit = document.getElementById("btn-submit");
        btnSubmit.disabled = false;

        // Se for "LIVRE", botão fica verde pra Agendar. Se tiver ID, botão fica laranja de Espera
        if (horarioCompleto.includes("LIVRE")) {
            btnSubmit.innerText = "Agendar Consulta";
            btnSubmit.classList.remove("btn-espera-laranja");
        } else {
            btnSubmit.innerText = "Entrar na Lista de Espera";
            btnSubmit.classList.add("btn-espera-laranja");
        }
    }

    function limparTudo() {
        document.getElementById("calendario-dias").innerHTML = "";
        document.getElementById("mes-atual").innerText = "Aguardando Seleção...";
        document.getElementById("grade-horarios").innerHTML = "";
        document.getElementById("titulo-horarios").innerText = "Selecione um dia";
        document.getElementById("legenda-horarios").style.display = "none";
        var btnSubmit = document.getElementById("btn-submit");
        btnSubmit.disabled = true;
        btnSubmit.innerText = "Agendar";
        btnSubmit.classList.remove("btn-espera-laranja");
        agendaDatasGlobal = [];
    }
    
	document.getElementById('formAgendamento').addEventListener('submit', function(event) {
        
        // Obtém os elementos select para pegar os textos das opções selecionadas
        const selectEspecialidade = document.getElementById('especialidade');
        const selectMedico = document.getElementById('medico');
        
        // Extrai os valores e textos
        const especialidadeNome = selectEspecialidade.options[selectEspecialidade.selectedIndex].text;
        const medicoNome = selectMedico.options[selectMedico.selectedIndex].text;
        const dataEscolhida = document.getElementById('data_escolhida').value;
        const horarioEscolhidoRaw = document.getElementById('horario_escolhido').value;
        
        // Define se é um agendamento direto ou lista de espera com base na string do horário
        const isListaEspera = !horarioEscolhidoRaw.includes("LIVRE");
        
        // Cria o objeto com os dados da consulta
        const dadosConsulta = {
            especialidade: especialidadeNome,
            medico: medicoNome,
            data: dataEscolhida,
            horarioRaw: horarioEscolhidoRaw, // Mantém o valor original enviado ao backend
            tipo: isListaEspera ? 'Espera' : 'Confirmado',
            dataRegistro: new Date().toISOString()
        };

        // Converte o objeto para string JSON e salva no localStorage
        localStorage.setItem('dadosUltimaConsulta', JSON.stringify(dadosConsulta));
        
        // Opcional: Se você quiser visualizar no console antes da página recarregar
        // console.log("Dados salvos no localStorage:", JSON.parse(localStorage.getItem('dadosUltimaConsulta')));
    });
</script>

</body>
</html>