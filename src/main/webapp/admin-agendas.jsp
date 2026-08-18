<%@page import="com.example.main.models.Perfil"%>
<%@page import="com.example.main.models.AgendaMedico"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null || usuarioLogado.getUsuario() == null || !usuarioLogado.getUsuario().isAdmUsuario()) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String sucesso = request.getParameter("sucesso");
    
    @SuppressWarnings("unchecked")
    HashSet<AgendaMedico> listaAgendas = (HashSet<AgendaMedico>) request.getAttribute("listaAgendas");
    
    DateTimeFormatter formatoData = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter formatoHora = DateTimeFormatter.ofPattern("HH:mm");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Agendas Médicas</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body.home-body, .dashboard-layout { height: 100vh; overflow: hidden; margin: 0; }
        .main-content { display: flex; flex-direction: column; height: 100vh; overflow: hidden; background-color: #F7FAFC; position: relative;}
        
        .topbar-admin { background-color: #12A388; padding: 24px 40px; color: #FFFFFF; flex-shrink: 0; display: flex; justify-content: space-between; align-items: center; }
        .topbar-admin h2 { font-size: 22px; margin: 0; font-weight: 700; }

        .scroll-area-admin { flex-grow: 1; overflow-y: auto; overflow-x: hidden; padding: 32px 40px; min-height: 0; }
        .scroll-area-admin::-webkit-scrollbar { width: 6px; }
        .scroll-area-admin::-webkit-scrollbar-thumb { background-color: #CBD5E0; border-radius: 4px; }

        .toast-sucesso { position: fixed; top: 24px; right: 40px; background-color: #E6FFFA; color: #12A388; padding: 16px 24px; border-radius: 8px; border: 1px solid #12A388; font-size: 14px; font-weight: bold; box-shadow: 0 4px 12px rgba(0,0,0,0.1); display: flex; align-items: center; justify-content: space-between; gap: 24px; z-index: 9999; transition: opacity 0.3s ease; }
        .toast-conteudo { display: flex; align-items: center; gap: 12px; }
        .toast-fechar { cursor: pointer; color: #12A388; font-size: 18px; transition: 0.2s; }
        .toast-fechar:hover { color: #0e826c; }

        .toolbar-container { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px; }
        .toolbar-left { display: flex; gap: 16px; align-items: center; flex-wrap: wrap; }
        .search-box { position: relative; width: 300px; }
        .search-box i { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: #A0AEC0; }
        .search-box input { width: 100%; padding: 12px 16px 12px 40px; border: 1px solid #E2E8F0; border-radius: 8px; font-size: 14px; outline: none; transition: 0.2s; box-sizing: border-box; }
        .search-box input:focus { border-color: #12A388; box-shadow: 0 0 0 3px rgba(18, 163, 136, 0.1); }
        
        .btn-nova-agenda { background-color: #12A388; color: white; border: none; padding: 12px 24px; border-radius: 8px; font-size: 14px; font-weight: bold; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s; }
        .btn-nova-agenda:hover { background-color: #0e826c; }

        .table-wrapper { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .admin-table { width: 100%; border-collapse: collapse; }
        .admin-table thead { background-color: #F7FAFC; border-bottom: 2px solid #E2E8F0; }
        .admin-table th { padding: 16px 24px; text-align: left; font-size: 12px; color: #718096; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; }
        .admin-table td { padding: 16px 24px; font-size: 14px; color: #2D3748; border-bottom: 1px solid #E2E8F0; vertical-align: middle; }
        .admin-table tr:last-child td { border-bottom: none; }
        
        .medico-cell { display: flex; flex-direction: column; gap: 4px; }
        .medico-name { font-weight: 700; color: #2D3748; }
        .medico-esp { font-size: 12px; color: #718096; }

        .agenda-data { font-weight: bold; color: #2D3748; display: flex; align-items: center; gap: 8px; }
        .agenda-horario { display: inline-block; background-color: #EDF2F7; color: #4A5568; padding: 6px 12px; border-radius: 6px; font-size: 13px; font-weight: bold; letter-spacing: 0.5px; }

        .status-disponivel { color: #38A169; font-weight: bold; display: flex; align-items: center; gap: 6px; font-size: 13px; }
        .status-bloqueada { color: #E53E3E; font-weight: bold; display: flex; align-items: center; gap: 6px; font-size: 13px; }

        .btn-icon { background: transparent; border: none; color: #A0AEC0; font-size: 16px; cursor: pointer; transition: 0.2s; padding: 6px; border-radius: 6px; display: inline-flex; align-items: center; justify-content: center; text-decoration: none;}
        .btn-icon:hover { color: #2D3748; background-color: #EDF2F7; }

        .modal-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background-color: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; opacity: 0; visibility: hidden; transition: 0.3s; }
        .modal-overlay.active { opacity: 1; visibility: visible; }
        .modal-content { background-color: #FFFFFF; border-radius: 16px; width: 100%; max-width: 520px; padding: 32px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); transform: translateY(20px); transition: 0.3s; }
        .modal-overlay.active .modal-content { transform: translateY(0); }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .modal-header h3 { margin: 0; font-size: 20px; color: #2D3748; }
        .btn-close-modal { background: none; border: none; font-size: 20px; color: #A0AEC0; cursor: pointer; }
        
        .grid-form { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .input-group-modal { margin-bottom: 16px; text-align: left; }
        .input-group-modal.full-width { grid-column: span 2; }
        .input-group-modal label { display: block; font-size: 13px; color: #4A5568; margin-bottom: 6px; font-weight: bold; }
        .input-group-modal select, .input-group-modal input { width: 100%; padding: 12px 16px; border: 1px solid #CBD5E0; border-radius: 8px; box-sizing: border-box; font-size: 14px; outline: none; transition: 0.2s; background-color: #FFFFFF; color: #2D3748; }
        .input-group-modal select:focus, .input-group-modal input:focus { border-color: #12A388; box-shadow: 0 0 0 3px rgba(18, 163, 136, 0.1); }
        
        .btn-salvar-modal { background-color: #12A388; color: white; border: none; width: 100%; padding: 14px; border-radius: 8px; font-size: 15px; font-weight: bold; cursor: pointer; margin-top: 16px; transition: 0.2s; }
        .btn-salvar-modal:hover { background-color: #0e826c; }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="admin-home" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
            <a href="admin-usuarios" class="nav-item"><i class="fa-solid fa-users"></i> Usuários</a>
            <a href="admin-consultas" class="nav-item"><i class="fa-solid fa-calendar-check"></i> Consultas</a>
            <a href="admin-agendas" class="nav-item active"><i class="fa-solid fa-calendar-plus"></i> Agendas Médicas</a>
            <a href="admin-listas-espera" class="nav-item"><i class="fa-solid fa-hourglass-half"></i> Listas de Espera</a>
            <a href="editar-perfil" class="nav-item"><i class="fa-solid fa-user"></i> Meu Perfil</a>
        </ul>
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Tem certeza que deseja sair do sistema?');">
            <i class="fa-solid fa-arrow-right-from-bracket"></i> Sair
        </a>
    </aside>

    <main class="main-content">
        
        <% if ("criada".equals(sucesso)) { %>
            <div id="toast-alerta" class="toast-sucesso">
                <div class="toast-conteudo">
                    <i class="fa-solid fa-circle-check"></i> 
                    <span>Agenda criada com sucesso!</span>
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
        <% } %>

        <header class="topbar-admin">
            <h2>Gerenciar Agendas</h2>
            <i class="fa-regular fa-bell" style="font-size: 22px; cursor: pointer;"></i>
        </header>

        <div class="scroll-area-admin">
            
            <div class="toolbar-container">
                <div class="toolbar-left">
                    <div class="search-box">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="inputBusca" placeholder="Buscar por médico ou especialidade..." onkeyup="filtrarTabela()">
                    </div>
                </div>

                <button class="btn-nova-agenda" onclick="abrirModal()">
                    <i class="fa-solid fa-calendar-plus"></i> Nova Agenda
                </button>
            </div>

            <div class="table-wrapper">
                <table class="admin-table" id="tabelaAgendas">
                    <thead>
                        <tr>
                            <th>Médico</th>
                            <th>Data</th>
                            <th>Faixa de Horário (Turno)</th>
                            <th>Status</th>
                            <th style="text-align: right;">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (listaAgendas != null && !listaAgendas.isEmpty()) {
                                for (AgendaMedico ag : listaAgendas) {
                                    String nomeMedico = "Dr(a). " + ag.getMedico().getUsuario().getNomeUsuario() + " " + ag.getMedico().getUsuario().getSobrenomeUsuario();
                                    String especialidade = ag.getEspecialidade().getNomeEspecialidade();
                                    String dataFormatada = ag.getDataAgenda().format(formatoData);
                                    String horarioFormatado = ag.getHoraInicio().format(formatoHora) + " - " + ag.getHoraFim().format(formatoHora);
                                    
                                    boolean isDisponivel = "Disponivel".equalsIgnoreCase(ag.getStatusAgenda());
                                    String statusClass = isDisponivel ? "status-disponivel" : "status-bloqueada";
                                    String statusTexto = isDisponivel ? "Disponível" : "Bloqueada";
                        %>
                        <tr>
                            <td>
                                <div class="medico-cell">
                                    <span class="medico-name"><%= nomeMedico %></span>
                                    <span class="medico-esp"><%= especialidade %></span>
                                </div>
                            </td>
                            <td>
                                <span class="agenda-data"><i class="fa-regular fa-calendar"></i> <%= dataFormatada %></span>
                            </td>
                            <td>
                                <span class="agenda-horario"><i class="fa-regular fa-clock"></i> <%= horarioFormatado %></span>
                            </td>
                            <td>
                                <span class="<%= statusClass %>"><i class="fa-solid fa-circle" style="font-size: 8px;"></i> <%= statusTexto %></span>
                            </td>
                            <td style="text-align: right;">
							    <button class="btn-icon" title="Alternar Status"><i class="fa-solid <%= isDisponivel ? "fa-ban" : "fa-unlock" %>"></i></button>
							</td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="5" style="text-align: center; color: #A0AEC0; padding: 32px;">Nenhuma agenda cadastrada no sistema.</td>
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

<!-- MODAL CADASTRAR AGENDA -->
<div class="modal-overlay" id="modalAgenda">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Disponibilizar Nova Agenda</h3>
            <button class="btn-close-modal" onclick="fecharModal()"><i class="fa-solid fa-xmark"></i></button>
        </div>
        
        <form action="admin-agendas" method="POST">
            <input type="hidden" name="acao" value="nova_agenda">
            
            <div class="input-group-modal full-width">
                <label>Médico</label>
                <select id="selectMedico" name="medico" required onchange="carregarEspecialidades()">
                    <option value="" disabled selected>Selecione o profissional...</option>
                    <%
                        List<Perfil> listaMedicos = (List<Perfil>) request.getAttribute("listaMedicos");
                        HashSet<com.example.main.models.Especialidade> todasEsp = (HashSet<com.example.main.models.Especialidade>) request.getAttribute("todasEspecialidades");
                        
                        if (listaMedicos != null) {
                            for (Perfil med : listaMedicos) {
                                List<Integer> espIds = com.example.main.dao.EspecialidadeDAO.getIdsEspecialidadesDoMedico(med.getIdPerfil());
                                String espData = "";
                                if (todasEsp != null) {
                                    for (com.example.main.models.Especialidade e : todasEsp) {
                                        if (espIds.contains(e.getIdEspecialidade())) {
                                            String nomeTipo = e.getTipoEspecialidade() != null ? e.getTipoEspecialidade().name() : "Especialidade";
                                            espData += e.getIdEspecialidade() + ":" + nomeTipo + "|";
                                        }
                                    }
                                }
                    %>
                    <option value="<%= med.getIdPerfil() %>" data-esp="<%= espData %>">
                        Dr(a). <%= med.getUsuario().getNomeUsuario() %> <%= med.getUsuario().getSobrenomeUsuario() %>
                    </option>
                    <%      }
                        }
                    %>
                </select>
            </div>

            <div class="input-group-modal full-width">
                <label>Especialidade</label>
                <select id="selectEspecialidade" name="especialidade" required>
                    <option value="" disabled selected>Selecione um médico primeiro...</option>
                </select>
            </div>

            <div class="grid-form">
                <div class="input-group-modal">
                    <label>Data do Atendimento</label>
                    <input type="date" name="data_agenda" required>
                </div>
            </div>

            <div class="grid-form">
                <div class="input-group-modal">
                    <label>Horário de Início</label>
                    <input type="time" name="hora_inicio" required>
                </div>
                
                <div class="input-group-modal">
                    <label>Horário de Término</label>
                    <input type="time" name="hora_fim" required>
                </div>
            </div>

            <button type="submit" class="btn-salvar-modal">Salvar Turno Médico</button>
        </form>
    </div>
</div>

<script>
    function abrirModal() { document.getElementById('modalAgenda').classList.add('active'); }
    function fecharModal() { document.getElementById('modalAgenda').classList.remove('active'); }

    function carregarEspecialidades() {
        var selectMedico = document.getElementById("selectMedico");
        var selectEsp = document.getElementById("selectEspecialidade");
        var espData = selectMedico.options[selectMedico.selectedIndex].getAttribute("data-esp");

        selectEsp.innerHTML = '<option value="" disabled selected>Selecione a especialidade...</option>';

        if (espData) {
            var especialidades = espData.split("|");
            especialidades.forEach(function(item) {
                if (item) {
                    var partes = item.split(":");
                    var option = document.createElement("option");
                    option.value = partes[0];
                    option.text = partes[1];
                    selectEsp.appendChild(option);
                }
            });
        } else {
            selectEsp.innerHTML = '<option value="" disabled selected>Nenhuma especialidade vinculada.</option>';
        }
    }

    function filtrarTabela() {
        let input = document.getElementById("inputBusca").value.toUpperCase();
        let tabela = document.getElementById("tabelaAgendas");
        let linhas = tabela.getElementsByTagName("tbody")[0].getElementsByTagName("tr");

        for (let i = 0; i < linhas.length; i++) {
            let celulaMedico = linhas[i].getElementsByTagName("td")[0];
            let celulaEsp = linhas[i].getElementsByTagName("td")[1]; // Se quiser pesquisar por especialidade tbm
            
            if (celulaMedico) {
                let texto = celulaMedico.textContent || celulaMedico.innerText;
                linhas[i].style.display = texto.toUpperCase().indexOf(input) > -1 ? "" : "none";
            }
        }
    }
</script>

</body>
</html>