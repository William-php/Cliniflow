<%@page import="com.example.main.models.Perfil"%>
<%@page import="com.example.main.models.Usuario"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Usuario usr = usuarioLogado.getUsuario();
    // Movemos o isAdm para o topo para usá-lo em toda a tela
    boolean isAdm = (usr != null && usr.isAdmUsuario());
    
    String nome = (usr != null && usr.getNomeUsuario() != null) ? usr.getNomeUsuario() : "";
    String sobrenome = (usr != null && usr.getSobrenomeUsuario() != null) ? usr.getSobrenomeUsuario() : "";
    String email = (usr != null && usr.getEmailUsuario() != null) ? usr.getEmailUsuario() : "";
    String cpf = (usr != null && usr.getCpfUsuario() != null) ? usr.getCpfUsuario() : "";
    String sexo = (usr != null && usr.getSexoUsuario() != null) ? usr.getSexoUsuario().name() : "";

    // Precisamos de dois formatos de data: Um pro Paciente ver (BR) e um pro Admin editar (HTML/ISO)
    String dataNascimentoBR = "";
    String dataNascimentoHTML = "";
    if (usr != null && usr.getDataNascimentoUsuario() != null) {
        dataNascimentoBR = usr.getDataNascimentoUsuario().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        dataNascimentoHTML = usr.getDataNascimentoUsuario().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }

    String inicialNome = !nome.isEmpty() ? nome.substring(0, 1).toUpperCase() : "U";
    String inicialSobrenome = !sobrenome.isEmpty() ? sobrenome.substring(0, 1).toUpperCase() : "";
    String iniciais = inicialNome + inicialSobrenome;
    
    String erro = request.getParameter("erro");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Perfil</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body.home-body, .dashboard-layout { height: 100vh; overflow: hidden; margin: 0; }
        .main-content { display: flex; flex-direction: column; height: 100vh; overflow: hidden; background-color: #FFFFFF; }
        
        .header-clean { flex-shrink: 0; padding: 32px 40px 0 40px; display: flex; justify-content: space-between; align-items: center; }
        .header-clean h2 { font-size: 24px; color: #2D3748; margin: 0; }

        .scroll-area-perfil { flex-grow: 1; overflow-y: auto; overflow-x: hidden; padding-bottom: 40px; }
        .scroll-area-perfil::-webkit-scrollbar { width: 6px; }
        .scroll-area-perfil::-webkit-scrollbar-thumb { background-color: #CBD5E0; border-radius: 4px; }

        .perfil-container { max-width: 440px; width: 100%; margin: 20px auto 40px auto; display: flex; flex-direction: column; align-items: center; padding: 0 20px; box-sizing: border-box; }

        .avatar-wrapper { position: relative; margin-bottom: 28px; }
        .avatar-circle { width: 88px; height: 88px; border-radius: 50%; border: 3px solid #12A388; display: flex; justify-content: center; align-items: center; font-size: 28px; font-weight: bold; color: #12A388; background-color: #FFFFFF; }
        .avatar-edit-icon { position: absolute; bottom: 2px; right: 2px; background-color: #12A388; color: white; width: 24px; height: 24px; border-radius: 50%; display: flex; justify-content: center; align-items: center; font-size: 11px; border: 2px solid #FFFFFF; cursor: pointer; }

        .perfil-form { width: 100%; }
        .input-group-perfil { margin-bottom: 16px; text-align: left; }
        .input-group-perfil label { display: block; font-size: 12px; color: #A0AEC0; margin-bottom: 6px; }
        .input-group-perfil input { width: 100%; padding: 14px 16px; border: 1px solid #E2E8F0; border-radius: 10px; box-sizing: border-box; font-size: 15px; color: #2D3748; background-color: #FFFFFF; outline: none; transition: border-color 0.2s; }
        .input-group-perfil input:focus:not([readonly]) { border-color: #12A388; }
        .input-group-perfil input[readonly] { background-color: #F0F4F8; color: #A0AEC0; cursor: not-allowed; border-color: #E2E8F0; }

        /* Estilização dos Radios de Sexo */
        .radio-group { display: flex; gap: 16px; padding: 12px 0; }
        .radio-label { display: flex; align-items: center; gap: 8px; font-size: 14px; color: #2D3748; cursor: pointer; }
        .radio-label input[type="radio"] { width: 18px; height: 18px; margin: 0; cursor: pointer; accent-color: #12A388; }

        .btn-salvar { background-color: #12A388; color: white; border: none; width: 100%; padding: 14px; border-radius: 10px; font-size: 16px; font-weight: bold; cursor: pointer; margin-top: 12px; margin-bottom: 12px; transition: background-color 0.2s; }
        .btn-salvar:hover { background-color: #0e826c; }
        .btn-deletar { background-color: transparent; color: #E53E3E; border: 1px solid #FC8181; width: 100%; padding: 14px; border-radius: 10px; font-size: 16px; font-weight: bold; cursor: pointer; text-align: center; transition: background-color 0.2s; }
        .btn-deletar:hover { background-color: #FFF5F5; }
        
        .alert-error { background-color: #FFF5F5; color: #E53E3E; padding: 14px 24px; border-radius: 8px; margin: 24px 40px 0 40px; font-weight: bold; border: 1px solid #FC8181; font-size: 14px; }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <!-- BARRA LATERAL DINÂMICA (Renderiza conforme o Perfil) -->
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <%
                String tipoPerfilMenu = usuarioLogado.getTipoPerfil() != null ? usuarioLogado.getTipoPerfil().name() : "";
                boolean isAdmMenu = usuarioLogado.getUsuario() != null && usuarioLogado.getUsuario().isAdmUsuario();

                // 1. MENU DO ADMINISTRADOR
                if (isAdmMenu) {
            %>
                    <a href="admin-home" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
                    <a href="admin-usuarios" class="nav-item"><i class="fa-solid fa-users"></i> Usuários</a>
                    <a href="admin-consultas" class="nav-item"><i class="fa-solid fa-calendar-check"></i> Consultas</a>
                    <a href="admin-agendas" class="nav-item"><i class="fa-solid fa-calendar-plus"></i> Agendas Médicas</a>
                    <a href="admin-listas-espera" class="nav-item"><i class="fa-solid fa-hourglass-half"></i> Listas de Espera</a>
                    <a href="editar-perfil" class="nav-item active"><i class="fa-solid fa-user"></i> Meu Perfil</a>

            <% 
                // 2. MENU DO MÉDICO
                } else if ("MEDICO".equalsIgnoreCase(tipoPerfilMenu)) { 
            %>
                    <a href="medico-home" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
                    <a href="medico-agenda" class="nav-item"><i class="fa-solid fa-calendar-days"></i> Minha Agenda</a>
                    <a href="editar-perfil" class="nav-item active"><i class="fa-solid fa-user-doctor"></i> Perfil</a>
                    <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>

            <% 
                // 3. MENU DO PACIENTE (Padrão)
                } else { 
            %>
                    <a href="home" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
                    <a href="minhas-consultas" class="nav-item"><i class="fa-solid fa-notes-medical"></i> Consultas</a>
                    <a href="minha-lista-espera" class="nav-item"><i class="fa-solid fa-hourglass-start"></i> Lista(s) de Espera</a>
                    <a href="editar-perfil" class="nav-item active"><i class="fa-solid fa-user"></i> Perfil</a>
                    <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
            <% } %>
        </ul>
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Tem certeza que deseja sair do sistema?');">
            <i class="fa-solid fa-arrow-right-from-bracket"></i> Sair
        </a>
    </aside>

    <main class="main-content">
        
        <% if ("falha_inativar".equals(erro) || "excecao".equals(erro)) { %>
            <div class="alert-error">
                <i class="fa-solid fa-triangle-exclamation"></i> Ocorreu um erro ao processar sua solicitação. Tente novamente mais tarde.
            </div>
        <% } %>

        <header class="header-clean">
            <h2>Meu Perfil</h2>
            <i class="fa-regular fa-bell" style="font-size: 24px; color: #A0AEC0; cursor: pointer;"></i>
        </header>

        <div class="scroll-area-perfil">
            <div class="perfil-container">
                
                <div class="avatar-wrapper">
                    <div class="avatar-circle">
                        <%= iniciais %>
                    </div>
                    <div class="avatar-edit-icon" title="Editar foto">
                        <i class="fa-solid fa-pen"></i>
                    </div>
                </div>

                <form action="usuario" method="POST" class="perfil-form">
                    
                    <div class="input-group-perfil">
                        <label>Nome</label>
                        <input type="text" name="nome_usuario" value="<%= nome %>" required>
                    </div>

                    <div class="input-group-perfil">
                        <label>Sobrenome</label>
                        <input type="text" name="sobrenome_usuario" value="<%= sobrenome %>" required>
                    </div>

                    <div class="input-group-perfil">
                        <label>Data de Nascimento</label>
                        <% if (isAdm) { %>
                            <input type="date" name="data_nascimento_usuario" value="<%= dataNascimentoHTML %>" required>
                        <% } else { %>
                            <input type="text" value="<%= dataNascimentoBR %>" readonly>
                        <% } %>
                    </div>

                    <div class="input-group-perfil">
                        <label>CPF</label>
                        <% if (isAdm) { %>
                            <!-- Se for admin, o input ganha o 'name' para ser enviado no form -->
                            <input type="text" name="cpf_usuario" value="<%= cpf %>" required>
                        <% } else { %>
                            <input type="text" value="<%= cpf %>" readonly>
                        <% } %>
                    </div>

                    <div class="input-group-perfil">
                        <label>Sexo</label>
                        <% if (isAdm) { %>
                            <div class="radio-group">
                                <label class="radio-label">
                                    <input type="radio" name="sexo_usuario" value="MASCULINO" <%= "MASCULINO".equalsIgnoreCase(sexo) ? "checked" : "" %> required> Masculino
                                </label>
                                <label class="radio-label">
                                    <input type="radio" name="sexo_usuario" value="FEMININO" <%= "FEMININO".equalsIgnoreCase(sexo) ? "checked" : "" %> required> Feminino
                                </label>
                            </div>
                        <% } else { %>
                            <input type="text" value="<%= "MASCULINO".equalsIgnoreCase(sexo) ? "Masculino" : ("FEMININO".equalsIgnoreCase(sexo) ? "Feminino" : "Não informado") %>" readonly>
                        <% } %>
                    </div>

                    <div class="input-group-perfil">
                        <label>E-mail</label>
                        <input type="email" name="email_usuario" value="<%= email %>" required>
                    </div>

                    <button type="submit" class="btn-salvar">Salvar Alterações</button>
                </form>

                <form action="deletar-conta" method="POST" class="perfil-form" onsubmit="return confirm('Atenção: Deseja realmente excluir/desativar sua conta? Você perderá o acesso ao sistema.');">
                    <button type="submit" class="btn-deletar">Deletar Conta</button>
                </form>

            </div>
        </div>
    </main>
</div>

</body>
</html>