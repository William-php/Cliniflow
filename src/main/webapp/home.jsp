<%@page import="com.example.main.models.Perfil"%>
<%@page import="com.example.main.models.Consulta"%>
<%@page import="java.util.HashSet"%>

<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.html");
        return;
    }
    String nomeUsuario = usuarioLogado.getUsuario() != null ? usuarioLogado.getUsuario().getNomeUsuario() : "Usuário";
    
    // Recuperamos a lista aqui no topo para usar tanto no Calendário quanto no Loop
    @SuppressWarnings("unchecked")
    HashSet<Consulta> lista = (HashSet<Consulta>) request.getAttribute("consultasUsuarioLogado");

    // LÓGICA DO CALENDÁRIO: Extrai as datas das consultas "Agendadas"
    StringBuilder datasConsultas = new StringBuilder("[");
    if (lista != null && !lista.isEmpty()) {
        for (Consulta c : lista) {
            if (c.getDataHoraInicioConsulta() != null && "AGENDADA".equalsIgnoreCase(c.getStatusConsulta() != null ? c.getStatusConsulta().name() : "")) {
                // Pega apenas a data (YYYY-MM-DD) cortando a parte do horário (T)
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
        /* Estilos do Calendário Dinâmico */
        .calendar-box { text-align: center; margin-top: 16px; }
        .calendar-nav { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding: 0 10px; }
        .btn-mes { background: none; border: none; cursor: pointer; color: #12A388; font-size: 18px; padding: 5px 10px; transition: 0.2s; }
        .btn-mes:hover { background-color: #E6FFFA; border-radius: 8px; }
        .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 8px; text-align: center; }
        .calendar-header { font-weight: bold; color: #A0AEC0; font-size: 14px; padding-bottom: 8px; }
        .calendar-day { padding: 10px; font-size: 14px; color: #4A5568; border-radius: 50%; border: 2px solid transparent; }
        .calendar-day.muted { color: #CBD5E0; }
        /* Dia com consulta marcada */
        .calendar-day.has-agenda { background-color: #E6FFFA; color: #12A388; border-color: #12A388; font-weight: bold; }
        /* Dia atual (Hoje) */
        .calendar-day.hoje { background-color: #2D3748; color: white; }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <!-- BARRA LATERAL -->
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="#" class="nav-item active"><i class="fa-solid fa-house"></i> Início</a>
            <a href="minhas-consultas" class="nav-item"><i class="fa-solid fa-notes-medical"></i> Consultas</a>
            <a href="minha-lista-espera" class="nav-item"><i class="fa-solid fa-hourglass-start"></i> Lista(s) de Espera</a>
            <a href="/cliniflow/editar-perfil.jsp" class="nav-item"><i class="fa-solid fa-user"></i> Perfil</a>
            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
        </ul>
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Tem certeza que deseja sair do sistema?');"><i class="fa-solid fa-arrow-right-from-bracket"></i> Sair</a>
    </aside>

    <!-- ÁREA PRINCIPAL -->
    <main class="main-content">
        <!-- MENSAGEM FLUTUANTE DE DADOS ATUALIZADOS -->
        <% 
            String atualizado = request.getParameter("atualizado");
            if ("true".equals(atualizado)) {
        %>
            <div id="toast-alerta" class="toast-sucesso">
                <div class="toast-conteudo">
                    <i class="fa-solid fa-circle-check"></i> 
                    <span>Perfil atualizado com sucesso!</span>
                </div>
                <!-- O "X" para fechar -->
                <i class="fa-solid fa-xmark toast-fechar" onclick="fecharToast()"></i>
            </div>

            <!-- Pequeno script para fechar no "X" ou sumir sozinho após 4 segundos -->
            <script>
                setTimeout(fecharToast, 4000);

                function fecharToast() {
                    var toast = document.getElementById("toast-alerta");
                    if(toast) {
                        toast.style.opacity = "0"; // Faz sumir suavemente
                        setTimeout(() => toast.remove(), 300); // Remove do HTML após a animação
                    }
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
            <div style="font-size: 24px; cursor: pointer;"><i class="fa-regular fa-bell"></i></div>
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
                
                <!-- Botão Agendar e Título lado a lado -->
                <div class="header-consultas">
                    <h3 class="section-title" style="margin-bottom: 0;">Minhas Consultas</h3>
                    <button class="btn-agendar" onclick="window.location.href='agendamento'">
                        <i class="fa-solid fa-plus"></i> Agendar Consulta
                    </button>
                </div>

                <!-- Loop de Consultas -->
                <%
                    if (lista != null && !lista.isEmpty()) {
                        for (Consulta c : lista) {
                            String statusStr = c.getStatusConsulta() != null ? c.getStatusConsulta().name() : "Pendente";
                            String classeBadge = "badge-pendente"; 
                            if ("CANCELADA".equalsIgnoreCase(statusStr)) classeBadge = "badge-cancelada";
                            if ("CONCLUIDA".equalsIgnoreCase(statusStr)) classeBadge = "badge-concluida";
                            
                            // Resgatando nome do médico através da hierarquia: Consulta -> Perfil (Médico) -> Usuario -> Nome
                            String nomeMedico = "Dr(a). Indefinido";
                            if (c.getMedicoConsulta() != null && c.getMedicoConsulta().getUsuario() != null) {
                                nomeMedico = "Dr(a). " + c.getMedicoConsulta().getUsuario().getNomeUsuario();
                            }
                %>
                        <div class="card-consulta">
                            <h4 class="medico-nome"><%= nomeMedico %></h4>
                            <p class="especialidade">Clínico Geral</p>
                            <div class="rodape-consulta">
                                <span class="data"><%= c.getDataHoraInicioConsulta() != null ? c.getDataHoraInicioConsulta().toString().replace("T", " às ") : "" %></span>
                                <span class="<%= classeBadge %>"><%= statusStr %></span>
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
                
                <!-- Estrutura Interativa do Calendário -->
                <div class="calendar-box">
                    <div class="calendar-nav">
                        <button type="button" class="btn-mes" onclick="mudarMes(-1)"><i class="fa-solid fa-chevron-left"></i></button>
                        <h4 id="mes-ano-display" style="color: #2D3748; font-weight: bold; margin: 0; font-size: 18px;">Carregando...</h4>
                        <button type="button" class="btn-mes" onclick="mudarMes(1)"><i class="fa-solid fa-chevron-right"></i></button>
                    </div>
                    
                    <div class="calendar-grid" id="calendario-dias">
                        <!-- O JavaScript preencherá os dias aqui -->
                    </div>
                    
                    <!-- Legenda do Calendário -->
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

<!-- SCRIPTS DO CALENDÁRIO -->
<script>
    // O Java injeta a lista de datas neste array
    const datasComConsulta = <%= datasConsultas.toString() %>;
    
    // Configurações Iniciais
    let dataSistema = new Date();
    let mesAtual = dataSistema.getMonth();
    let anoAtual = dataSistema.getFullYear();

    const nomesMeses = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];

    function renderizarCalendario(mes, ano) {
        document.getElementById("mes-ano-display").innerText = nomesMeses[mes] + " " + ano;
        const grid = document.getElementById("calendario-dias");
        
        let cabecalho = '<div class="calendar-header">D</div><div class="calendar-header">S</div><div class="calendar-header">T</div><div class="calendar-header">Q</div><div class="calendar-header">Q</div><div class="calendar-header">S</div><div class="calendar-header">S</div>';
        let diasHtml = "";
        
        // Determina onde o mês começa e a quantidade de dias
        let primeiroDiaDoMes = new Date(ano, mes, 1).getDay(); 
        let qtdDiasNoMes = new Date(ano, mes + 1, 0).getDate();
        
        // Preenche os dias vazios da primeira semana
        for(let i = 0; i < primeiroDiaDoMes; i++) {
            diasHtml += '<div class="calendar-day muted"></div>';
        }
        
        // Loop que cria cada dia numerado
        for(let dia = 1; dia <= qtdDiasNoMes; dia++) {
            let dataString = ano + "-" + String(mes + 1).padStart(2, '0') + "-" + String(dia).padStart(2, '0');
            
            let classeExtra = "";
            let titleText = "";

            // Verifica se o dia renderizado é o dia atual do sistema
            if (dia === dataSistema.getDate() && mes === dataSistema.getMonth() && ano === dataSistema.getFullYear()) {
                classeExtra += " hoje";
            }
            
            // Verifica se este dia tem uma consulta marcada com base no array
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

    // Gatilho que dispara o calendário assim que a página é lida
    window.onload = function() {
        renderizarCalendario(mesAtual, anoAtual);
    };
</script>

</body>
</html>