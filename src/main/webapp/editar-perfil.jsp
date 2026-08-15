<%@page import="com.example.main.models.Perfil"%>
<%@page import="com.example.main.models.Usuario"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        response.sendRedirect("index.html");
        return;
    }

    Usuario usr = usuarioLogado.getUsuario();
    String nome = (usr != null && usr.getNomeUsuario() != null) ? usr.getNomeUsuario() : "";
    String sobrenome = (usr != null && usr.getSobrenomeUsuario() != null) ? usr.getSobrenomeUsuario() : "";
    String email = (usr != null && usr.getEmailUsuario() != null) ? usr.getEmailUsuario() : "";
    String cpf = (usr != null && usr.getCpfUsuario() != null) ? usr.getCpfUsuario() : "";

    String dataNascimento = "";
    if (usr != null && usr.getDataNascimentoUsuario() != null) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        dataNascimento = usr.getDataNascimentoUsuario().format(formatter);
    }

    // Gerando as iniciais para o Avatar Central
    String inicialNome = !nome.isEmpty() ? nome.substring(0, 1).toUpperCase() : "U";
    String inicialSobrenome = !sobrenome.isEmpty() ? sobrenome.substring(0, 1).toUpperCase() : "";
    String iniciais = inicialNome + inicialSobrenome;
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Perfil</title>
    <!-- CSS Padrão da Aplicação -->
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* Estilos específicos para a tela de Perfil */
        .header-clean { padding: 32px 40px 0 40px; display: flex; justify-content: space-between; align-items: center; }
        .header-clean h2 { font-size: 24px; color: #2D3748; display: flex; align-items: center; gap: 12px; }
        .header-clean h2 i { color: #12A388; cursor: pointer; }

        .perfil-container {
            max-width: 440px;
            width: 100%;
            margin: 10px auto 40px auto;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .avatar-wrapper {
            position: relative;
            margin-bottom: 28px;
        }

        .avatar-circle {
            width: 88px;
            height: 88px;
            border-radius: 50%;
            border: 3px solid #12A388;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 28px;
            font-weight: bold;
            color: #12A388;
            background-color: #FFFFFF;
        }

        .avatar-edit-icon {
            position: absolute;
            bottom: 2px;
            right: 2px;
            background-color: #12A388;
            color: white;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 11px;
            border: 2px solid #FFFFFF;
            cursor: pointer;
        }

        .perfil-form {
            width: 100%;
        }

        .input-group-perfil {
            margin-bottom: 16px;
            text-align: left;
        }

        .input-group-perfil label {
            display: block;
            font-size: 12px;
            color: #A0AEC0;
            margin-bottom: 6px;
        }

        .input-group-perfil input {
            width: 100%;
            padding: 14px 16px;
            border: 1px solid #E2E8F0;
            border-radius: 10px;
            box-sizing: border-box;
            font-size: 15px;
            color: #2D3748;
            background-color: #FFFFFF;
            outline: none;
            transition: border-color 0.2s;
        }

        .input-group-perfil input:focus:not([readonly]) {
            border-color: #12A388;
        }

        /* Campos bloqueados para edição (CPF e Data Nasc.) */
        .input-group-perfil input[readonly] {
            background-color: #F0F4F8;
            color: #A0AEC0;
            cursor: not-allowed;
            border-color: #E2E8F0;
        }

        .btn-salvar {
            background-color: #12A388;
            color: white;
            border: none;
            width: 100%;
            padding: 14px;
            border-radius: 10px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 12px;
            margin-bottom: 12px;
            transition: background-color 0.2s;
        }

        .btn-salvar:hover {
            background-color: #0e826c;
        }

        .btn-logout {
            background-color: transparent;
            color: #E53E3E;
            border: 1px solid #FC8181;
            width: 100%;
            padding: 14px;
            border-radius: 10px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            display: block;
            box-sizing: border-box;
            transition: background-color 0.2s;
        }

        .btn-logout:hover {
            background-color: #FFF5F5;
        }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <!-- BARRA LATERAL (Padrão do Projeto) -->
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="consultas" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
            <a href="minhas-consultas" class="nav-item"><i class="fa-solid fa-notes-medical"></i> Consultas</a>
            <a href="perfil" class="nav-item active"><i class="fa-solid fa-user"></i> Perfil</a>
            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
        </ul>
        <a href="index.html" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;"><i class="fa-solid fa-arrow-right-from-bracket"></i> Sair</a>
    </aside>

    <!-- ÁREA PRINCIPAL -->
    <main class="main-content" style="background-color: #FFFFFF;">
        
        <!-- Cabeçalho -->
        <header class="header-clean">
            <h2><i class="fa-solid fa-chevron-left" onclick="history.back()"></i> Perfil</h2>
        </header>

        <!-- Conteúdo do Perfil -->
        <div class="perfil-container">
            
            <!-- Avatar com Iniciais e Ícone de Edição -->
            <div class="avatar-wrapper">
                <div class="avatar-circle">
                    <%= iniciais %>
                </div>
                <div class="avatar-edit-icon">
                    <i class="fa-solid fa-pen"></i>
                </div>
            </div>

            <!-- Formulário de Alteração de Dados -->
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
                    <input type="text" value="<%= dataNascimento %>" readonly>
                </div>

                <div class="input-group-perfil">
                    <label>CPF</label>
                    <input type="text" value="<%= cpf %>" readonly>
                </div>

                <div class="input-group-perfil">
                    <label>E-mail</label>
                    <input type="email" name="email_usuario" value="<%= email %>" required>
                </div>

                <!-- Botões de Ação -->
                <button type="submit" class="btn-salvar">Salvar Alterações</button>
                <a href="index.html" class="btn-logout">Sair da Conta</a>

            </form>

        </div>

    </main>
</div>

</body>
</html>