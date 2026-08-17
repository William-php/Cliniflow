<%@page import="com.example.main.models.Perfil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Trava de segurança: Apenas Admin entra aqui
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null || usuarioLogado.getUsuario() == null || !usuarioLogado.getUsuario().isAdmUsuario()) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Gerenciar Usuários</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* =========================================================================
           ESTILOS DA TELA DE USUÁRIOS (Copiar para style.css posteriormente)
           ========================================================================= */
        body.home-body, .dashboard-layout { height: 100vh; overflow: hidden; margin: 0; }
        .main-content { display: flex; flex-direction: column; height: 100vh; overflow: hidden; background-color: #F7FAFC; }
        
        .topbar-admin { background-color: #12A388; padding: 24px 40px; color: #FFFFFF; flex-shrink: 0; display: flex; justify-content: space-between; align-items: center; }
        .topbar-admin h2 { font-size: 22px; margin: 0; font-weight: 700; }

        .scroll-area-admin { flex-grow: 1; overflow-y: auto; overflow-x: hidden; padding: 32px 40px; min-height: 0; }
        .scroll-area-admin::-webkit-scrollbar { width: 6px; }
        .scroll-area-admin::-webkit-scrollbar-thumb { background-color: #CBD5E0; border-radius: 4px; }

        /* BARRA DE FERRAMENTAS (Pesquisa, Filtros e Botão) */
        .toolbar-container { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px; }
        
        .toolbar-left { display: flex; gap: 16px; align-items: center; flex-wrap: wrap; }
        
        .search-box { position: relative; width: 300px; }
        .search-box i { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: #A0AEC0; }
        .search-box input { width: 100%; padding: 12px 16px 12px 40px; border: 1px solid #E2E8F0; border-radius: 8px; font-size: 14px; outline: none; transition: 0.2s; box-sizing: border-box; }
        .search-box input:focus { border-color: #12A388; box-shadow: 0 0 0 3px rgba(18, 163, 136, 0.1); }

        .filter-pills { display: flex; background-color: #EDF2F7; padding: 4px; border-radius: 8px; gap: 4px; }
        .pill-btn { background: transparent; border: none; padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: bold; color: #718096; cursor: pointer; transition: 0.2s; }
        .pill-btn.active { background-color: #FFFFFF; color: #2D3748; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }

        .btn-novo-usuario { background-color: #12A388; color: white; border: none; padding: 12px 24px; border-radius: 8px; font-size: 14px; font-weight: bold; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s; }
        .btn-novo-usuario:hover { background-color: #0e826c; }

        /* TABELA DE USUÁRIOS */
        .table-wrapper { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .admin-table { width: 100%; border-collapse: collapse; }
        .admin-table thead { background-color: #F7FAFC; border-bottom: 2px solid #E2E8F0; }
        .admin-table th { padding: 16px 24px; text-align: left; font-size: 12px; color: #718096; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; }
        .admin-table td { padding: 16px 24px; font-size: 14px; color: #2D3748; border-bottom: 1px solid #E2E8F0; vertical-align: middle; }
        .admin-table tr:last-child td { border-bottom: none; }
        
        /* Célula de Usuário (Nome + Email) */
        .user-cell { display: flex; flex-direction: column; gap: 4px; }
        .user-name { font-weight: 700; color: #2D3748; }
        .user-email { font-size: 12px; color: #718096; }

        /* Badges de Perfil e Status */
        .badge-paciente { background-color: #E6FFFA; color: #12A388; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge-medico { background-color: #FAF5FF; color: #805AD5; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .status-ativo { color: #38A169; font-weight: bold; display: flex; align-items: center; gap: 6px; font-size: 13px; }
        .status-inativo { color: #E53E3E; font-weight: bold; display: flex; align-items: center; gap: 6px; font-size: 13px; }

        /* Botões de Ação na Tabela */
        .btn-icon { background: transparent; border: none; color: #A0AEC0; font-size: 16px; cursor: pointer; transition: 0.2s; padding: 6px; border-radius: 6px; }
        .btn-icon:hover { color: #2D3748; background-color: #EDF2F7; }

        /* MODAL DE CADASTRO */
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background-color: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; opacity: 0; visibility: hidden; transition: 0.3s; }
        .modal-overlay.active { opacity: 1; visibility: visible; }
        .modal-content { background-color: #FFFFFF; border-radius: 16px; width: 100%; max-width: 480px; padding: 32px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); transform: translateY(20px); transition: 0.3s; }
        .modal-overlay.active .modal-content { transform: translateY(0); }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .modal-header h3 { margin: 0; font-size: 20px; color: #2D3748; }
        .btn-close-modal { background: none; border: none; font-size: 20px; color: #A0AEC0; cursor: pointer; }
        
        .modal-options { display: flex; gap: 16px; }
        .modal-card-btn { flex: 1; border: 2px solid #E2E8F0; border-radius: 12px; padding: 24px 16px; text-align: center; cursor: pointer; transition: 0.2s; text-decoration: none; display: flex; flex-direction: column; align-items: center; gap: 12px; color: #2D3748; }
        .modal-card-btn:hover { border-color: #12A388; background-color: #F7FAFC; }
        .modal-card-btn i { font-size: 32px; color: #12A388; }
        .modal-card-btn span { font-weight: bold; font-size: 15px; }
        /* ========================================================================= */
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <!-- BARRA LATERAL ADMINISTRATIVA -->
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="admin-home" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
            <a href="admin-usuarios" class="nav-item active"><i class="fa-solid fa-users"></i> Usuários</a>
            <a href="admin-consultas" class="nav-item"><i class="fa-solid fa-calendar-check"></i> Consultas</a>
            <a href="admin-agendas" class="nav-item"><i class="fa-solid fa-calendar-plus"></i> Agendas Médicas</a>
            <a href="admin-listas-espera" class="nav-item"><i class="fa-solid fa-hourglass-half"></i> Listas de Espera</a>
            <a href="editar-perfil" class="nav-item"><i class="fa-solid fa-user"></i> Meu Perfil</a>
        </ul>
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Tem certeza que deseja sair do sistema?');">
            <i class="fa-solid fa-arrow-right-from-bracket"></i> Sair
        </a>
    </aside>

    <!-- ÁREA PRINCIPAL -->
    <main class="main-content">
        
        <header class="topbar-admin">
            <h2>Gerenciar Usuários</h2>
            <i class="fa-regular fa-bell" style="font-size: 22px; cursor: pointer;"></i>
        </header>

        <div class="scroll-area-admin">
            
            <!-- BARRA DE FERRAMENTAS -->
            <div class="toolbar-container">
                <div class="toolbar-left">
                    <!-- Pesquisa -->
                    <div class="search-box">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="inputBusca" placeholder="Buscar por nome ou e-mail..." onkeyup="filtrarTabela()">
                    </div>

                    <!-- Filtros (Pills) -->
                    <div class="filter-pills">
                        <button class="pill-btn active" onclick="setFiltroPerfil('TODOS', this)">Todos</button>
                        <button class="pill-btn" onclick="setFiltroPerfil('PACIENTE', this)">Pacientes</button>
                        <button class="pill-btn" onclick="setFiltroPerfil('MEDICO', this)">Médicos</button>
                    </div>
                </div>

                <!-- Botão Novo Usuário -->
                <button class="btn-novo-usuario" onclick="abrirModal()">
                    <i class="fa-solid fa-plus"></i> Novo Usuário
                </button>
            </div>

            <!-- TABELA DE USUÁRIOS -->
            <div class="table-wrapper">
                <table class="admin-table" id="tabelaUsuarios">
                    <thead>
                        <tr>
                            <th>Usuário</th>
                            <th>Perfil</th>
                            <th>Status</th>
                            <th style="text-align: right;">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            @SuppressWarnings("unchecked")
                            java.util.HashSet<Perfil> listaUsuarios = (java.util.HashSet<Perfil>) request.getAttribute("listaUsuarios");
                            
                            if (listaUsuarios != null && !listaUsuarios.isEmpty()) {
                                for (Perfil p : listaUsuarios) {
                                    com.example.main.models.Usuario u = p.getUsuario();
                                    
                                    // Pega os dados do Java
                                    String tipoPerfil = p.getTipoPerfil() != null ? p.getTipoPerfil().name() : "INDEFINIDO";
                                    String status = u.getStatusUsuario() != null ? u.getStatusUsuario().name() : "INATIVO";
                                    String nomeCompleto = u.getNomeUsuario() + " " + u.getSobrenomeUsuario();
                                    
                                    // Configura as cores (CSS) dinamicamente
                                    String badgeClass = "PACIENTE".equalsIgnoreCase(tipoPerfil) ? "badge-paciente" : "badge-medico";
                                    String statusClass = "ATIVO".equalsIgnoreCase(status) ? "status-ativo" : "status-inativo";
                                    String iconStatus = "ATIVO".equalsIgnoreCase(status) ? "Ativo" : "Inativo";
                        %>
                        <tr data-perfil="<%= tipoPerfil %>">
                            <td>
                                <div class="user-cell">
                                    <span class="user-name"><%= nomeCompleto %></span>
                                    <span class="user-email"><%= u.getEmailUsuario() %></span>
                                </div>
                            </td>
                            <td><span class="<%= badgeClass %>"><%= tipoPerfil %></span></td>
                            <td><span class="<%= statusClass %>"><i class="fa-solid fa-circle" style="font-size: 8px;"></i> <%= iconStatus %></span></td>
                            <td style="text-align: right;">
                                <!-- Futuros botões de ação -->
                                <button class="btn-icon" title="Editar"><i class="fa-solid fa-pen-to-square"></i></button>
                                <% if ("ATIVO".equalsIgnoreCase(status)) { %>
                                    <button class="btn-icon" title="Bloquear"><i class="fa-solid fa-ban"></i></button>
                                <% } else { %>
                                    <button class="btn-icon" title="Reativar"><i class="fa-solid fa-rotate-left"></i></button>
                                <% } %>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                            <tr>
                                <td colspan="4" style="text-align: center; color: #A0AEC0; padding: 32px;">Nenhum usuário encontrado no sistema.</td>
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

<!-- MODAL DE SELEÇÃO DE NOVO CADASTRO -->
<div class="modal-overlay" id="modalCadastro">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Novo Cadastro</h3>
            <button class="btn-close-modal" onclick="fecharModal()"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <p style="color: #718096; font-size: 14px; margin-bottom: 24px; margin-top: -16px;">Selecione o tipo de perfil que deseja registrar no sistema.</p>
        
        <div class="modal-options">
            <a href="cadastro.html" class="modal-card-btn">
                <i class="fa-solid fa-hospital-user"></i>
                <span>Novo Paciente</span>
            </a>
            <a href="cadastro-medico.jsp" class="modal-card-btn" style="border-color: #E9D8FD; color: #805AD5;">
                <i class="fa-solid fa-user-doctor" style="color: #805AD5;"></i>
                <span>Novo Médico</span>
            </a>
        </div>
    </div>
</div>

<!-- SCRIPTS DE FILTRAGEM E MODAL -->
<script>
    let filtroAtual = 'TODOS';

    // Função para alterar o filtro de Perfil pelos botões
    function setFiltroPerfil(perfil, elementoClicado) {
        filtroAtual = perfil;
        
        // Remove a classe 'active' de todos os botões e coloca só no clicado
        document.querySelectorAll('.pill-btn').forEach(btn => btn.classList.remove('active'));
        elementoClicado.classList.add('active');
        
        filtrarTabela();
    }

    // Função que cruza a pesquisa de texto com o filtro de perfil
    function filtrarTabela() {
        let inputBusca = document.getElementById("inputBusca").value.toUpperCase();
        let tabela = document.getElementById("tabelaUsuarios");
        let linhas = tabela.getElementsByTagName("tbody")[0].getElementsByTagName("tr");

        for (let i = 0; i < linhas.length; i++) {
            let linha = linhas[i];
            let perfilLinha = linha.getAttribute("data-perfil");
            let celulaUsuario = linha.getElementsByTagName("td")[0];
            
            if (celulaUsuario) {
                let textoUsuario = celulaUsuario.textContent || celulaUsuario.innerText;
                
                // Verifica a busca em texto
                let matchBusca = textoUsuario.toUpperCase().indexOf(inputBusca) > -1;
                
                // Verifica o botão de perfil
                let matchPerfil = (filtroAtual === 'TODOS' || filtroAtual === perfilLinha);

                // Mostra a linha só se passar nos dois testes
                if (matchBusca && matchPerfil) {
                    linha.style.display = "";
                } else {
                    linha.style.display = "none";
                }
            }
        }
    }

    // Funções do Modal
    function abrirModal() {
        document.getElementById('modalCadastro').classList.add('active');
    }
    
    function fecharModal() {
        document.getElementById('modalCadastro').classList.remove('active');
    }
</script>

</body>
</html>