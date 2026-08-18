<%@page import="com.example.main.models.Perfil"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>
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
    <title>CliniFlow - Listas de Espera</title>
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

        .toast-sucesso { position: fixed; top: 24px; right: 40px; background-color: #E6FFFA; color: #12A388; padding: 16px 24px; border-radius: 8px; border: 1px solid #12A388; font-size: 14px; font-weight: bold; box-shadow: 0 4px 12px rgba(0,0,0,0.1); display: flex; align-items: center; justify-content: space-between; gap: 24px; z-index: 9999; }

        /* GRID DE CARDS COM BOLINHA VERDE */
        .filas-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 24px; margin-top: 16px; }
        .card-fila { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; padding: 24px; position: relative; box-shadow: 0 2px 4px rgba(0,0,0,0.02); display: flex; flex-direction: column; gap: 12px; }
        
        /* A BOLINHA VERDE MÁGICA */
        .bolinha-qtd { position: absolute; top: -12px; right: -12px; width: 36px; height: 36px; background-color: #12A388; color: #FFFFFF; border-radius: 50%; display: flex; justify-content: center; align-items: center; font-weight: bold; border: 3px solid #F7FAFC; box-shadow: 0 2px 5px rgba(18,163,136,0.3); font-size: 14px; }
        
        .cf-header h4 { margin: 0; font-size: 18px; color: #2D3748; }
        .cf-especialidade { margin: 0; font-size: 13px; color: #A0AEC0; text-transform: uppercase; font-weight: bold; }
        .cf-data { font-size: 14px; color: #4A5568; font-weight: 600; display: flex; align-items: center; gap: 8px; background: #F7FAFC; padding: 10px; border-radius: 8px; margin-top: 4px;}
        .cf-data i { color: #12A388; }
        
        .cf-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 12px; padding-top: 16px; border-top: 1px dashed #E2E8F0; }
        .btn-encerrar { background: transparent; border: none; color: #E53E3E; font-size: 13px; font-weight: bold; cursor: pointer; padding: 0; }
        .btn-encerrar:hover { text-decoration: underline; }
        .btn-ver-fila { background-color: #12A388; color: white; border: none; padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-ver-fila:hover { background-color: #0e826c; }

        /* MODAL LISTA DE PACIENTES */
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background-color: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; opacity: 0; visibility: hidden; transition: 0.3s; }
        .modal-overlay.active { opacity: 1; visibility: visible; }
        .modal-content { background-color: #FFFFFF; border-radius: 16px; width: 100%; max-width: 600px; padding: 32px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); transform: translateY(20px); transition: 0.3s; display: flex; flex-direction: column; max-height: 85vh; }
        .modal-overlay.active .modal-content { transform: translateY(0); }
        .modal-header { display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 1px solid #E2E8F0; padding-bottom: 16px; margin-bottom: 24px; }
        .modal-title-box h3 { margin: 0; font-size: 20px; color: #2D3748; }
        .modal-title-box p { margin: 4px 0 0 0; font-size: 14px; color: #718096; font-weight: 500; }
        .btn-close-modal { background: none; border: none; font-size: 20px; color: #A0AEC0; cursor: pointer; }
        
        .modal-body-scroll { overflow-y: auto; flex-grow: 1; padding-right: 8px; }
        .modal-body-scroll::-webkit-scrollbar { width: 6px; }
        .modal-body-scroll::-webkit-scrollbar-thumb { background-color: #CBD5E0; border-radius: 4px; }

        /* ITEM DO PACIENTE (1º, 2º...) */
        .fila-patient-item { display: flex; justify-content: space-between; align-items: center; padding: 16px; border: 1px solid #E2E8F0; border-radius: 12px; margin-bottom: 12px; background-color: #F7FAFC; transition: 0.2s; }
        .fila-patient-item:hover { border-color: #12A388; background-color: #FFFFFF; }
        .fpi-info { display: flex; align-items: center; gap: 16px; }
        .fpi-pos { font-size: 20px; font-weight: 900; color: #A0AEC0; width: 32px; }
        .fpi-name { font-size: 16px; font-weight: 700; color: #2D3748; }
        
        .fpi-actions { display: flex; gap: 8px; align-items: center; }
        .fpi-actions form { margin: 0; }
        .btn-alocar { background-color: #12A388; color: white; border: none; padding: 8px 16px; border-radius: 6px; font-size: 12px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-alocar:hover { background-color: #0e826c; }
        .btn-remover { background: transparent; border: 1px solid #FC8181; color: #E53E3E; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; transition: 0.2s; display: flex; align-items: center; justify-content: center; }
        .btn-remover:hover { background-color: #FFF5F5; }
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
            <a href="admin-agendas" class="nav-item"><i class="fa-solid fa-calendar-plus"></i> Agendas Médicas</a>
            <a href="admin-listas-espera" class="nav-item active"><i class="fa-solid fa-hourglass-half"></i> Listas de Espera</a>
            <a href="editar-perfil" class="nav-item"><i class="fa-solid fa-user"></i> Meu Perfil</a>
        </ul>
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Sair do sistema?');"><i class="fa-solid fa-arrow-right-from-bracket"></i> Sair</a>
    </aside>

    <main class="main-content">
        <% if (sucesso != null) { %>
            <div id="toast-alerta" class="toast-sucesso">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <i class="fa-solid fa-circle-check"></i> 
                    <span>Operação na fila realizada com sucesso!</span>
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
            <h2>Gerenciar Listas de Espera</h2>
            <i class="fa-regular fa-bell" style="font-size: 22px; cursor: pointer;"></i>
        </header>

        <div class="scroll-area-admin">
            <div style="margin-bottom: 24px;">
                <p style="color: #718096; font-size: 15px; margin: 0;">Visualize e gerencie os pacientes aguardando vagas em horários lotados.</p>
            </div>

            <div class="filas-grid">
                <%
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> filas = (List<Map<String, Object>>) request.getAttribute("filas");
                    @SuppressWarnings("unchecked")
                    HashMap<Integer, String> mapaEspecialidades = (HashMap<Integer, String>) request.getAttribute("mapaEspecialidades");
                    
                    if (filas != null && !filas.isEmpty()) {
                        for (Map<String, Object> fila : filas) {
                            int idConsulta = (Integer) fila.get("idConsulta");
                            int idMedico = (Integer) fila.get("idMedico");
                            String nomeMedico = (String) fila.get("nomeMedico");
                            int qtd = (Integer) fila.get("qtdPacientes");
                            
                            String especialidade = mapaEspecialidades != null && mapaEspecialidades.containsKey(idMedico) ? mapaEspecialidades.get(idMedico) : "Clínico Geral";
                            
                            LocalDateTime dataHora = (LocalDateTime) fila.get("dataHora");
                            String dataFormatada = dataHora != null ? dataHora.format(formatoBR) : "Data não definida";
                %>
                <div class="card-fila">
                    <div class="bolinha-qtd" title="<%= qtd %> paciente(s) na fila"><%= qtd %></div>
                    
                    <div class="cf-header">
                        <h4><%= nomeMedico %></h4>
                        <p class="cf-especialidade"><%= especialidade %></p>
                    </div>
                    
                    <div class="cf-data">
                        <i class="fa-regular fa-clock"></i> <%= dataFormatada %>
                    </div>
                    
                    <div class="cf-footer">
                        <form action="admin-listas-espera" method="POST" style="margin:0;" onsubmit="return confirm('Isso removerá TODOS os pacientes desta fila. Deseja encerrar?');">
                            <input type="hidden" name="acao" value="encerrar_fila">
                            <input type="hidden" name="id_consulta" value="<%= idConsulta %>">
                            <button type="submit" class="btn-encerrar">Encerrar Lista</button>
                        </form>
                        
                        <!-- Ao clicar, injetamos as variaveis no Modal via JS -->
                        <button class="btn-ver-fila" onclick="abrirModalFila(<%= idConsulta %>, '<%= nomeMedico %>', '<%= especialidade %>', '<%= dataFormatada %>')">Detalhes da Lista</button>
                    </div>
                </div>
                <%
                        }
                    } else {
                %>
                    <div style="grid-column: 1/-1; text-align: center; padding: 40px; background: #fff; border-radius: 12px; border: 1px dashed #CBD5E0;">
                        <i class="fa-solid fa-clipboard-check" style="font-size: 40px; color: #CBD5E0; margin-bottom: 16px;"></i>
                        <p style="color: #718096; font-size: 16px; margin: 0;">Não há nenhuma fila de espera ativa no momento.</p>
                    </div>
                <%
                    }
                %>
            </div>
        </div>
    </main>
</div>

<!-- MODAL COM A ORDEM DOS PACIENTES -->
<div class="modal-overlay" id="modalFila">
    <div class="modal-content">
        <div class="modal-header">
            <div class="modal-title-box">
                <h3>Fila de Espera</h3>
                <p id="modal-subtitulo">Carregando...</p>
            </div>
            <button class="btn-close-modal" onclick="fecharModalFila()"><i class="fa-solid fa-xmark"></i></button>
        </div>
        
        <div class="modal-body-scroll" id="lista-pacientes-ajax">
            <!-- O JAVASCRIPT INJETA A LISTA COM BOTÕES AQUI DENTRO -->
            <p style="text-align: center; color: #A0AEC0;">Carregando ordem dos pacientes...</p>
        </div>
    </div>
</div>

<script>
    function abrirModalFila(idConsulta, medico, especialidade, dataHora) {
        // Preenche o cabeçalho do Modal
        document.getElementById('modal-subtitulo').innerText = medico + " - " + especialidade + " | " + dataHora;
        document.getElementById('lista-pacientes-ajax').innerHTML = '<p style="text-align: center; color: #12A388;"><i class="fa-solid fa-circle-notch fa-spin"></i> Buscando pacientes...</p>';
        
        // Exibe o Modal na tela
        document.getElementById('modalFila').classList.add('active');

        // Busca a ordem dos pacientes no servidor (AJAX)
        fetch('admin-listas-espera?acao=buscar_pacientes&id_consulta=' + idConsulta)
            .then(response => response.text())
            .then(html => {
                document.getElementById('lista-pacientes-ajax').innerHTML = html;
            })
            .catch(error => {
                document.getElementById('lista-pacientes-ajax').innerHTML = '<p style="color: #E53E3E; text-align: center;">Erro ao carregar a fila.</p>';
            });
    }

    function fecharModalFila() {
        document.getElementById('modalFila').classList.remove('active');
    }
</script>

</body>
</html>