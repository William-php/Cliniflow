<%@page import="com.example.main.models.Perfil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Perfil adminLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (adminLogado == null || adminLogado.getUsuario() == null || !adminLogado.getUsuario().isAdmUsuario()) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Cadastrar Novo Médico</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body.home-body, .dashboard-layout { height: 100vh; overflow: hidden; margin: 0; }
        .main-content { display: flex; flex-direction: column; height: 100vh; overflow: hidden; background-color: #F7FAFC; }
        .topbar-admin { background-color: #12A388; padding: 24px 40px; color: #FFFFFF; flex-shrink: 0; display: flex; align-items: center; gap: 16px;}
        .topbar-admin h2 { font-size: 22px; margin: 0; font-weight: 700; }
        .btn-voltar { color: #FFFFFF; text-decoration: none; font-size: 20px; transition: 0.2s; }
        .btn-voltar:hover { opacity: 0.8; }
        
        .scroll-area-admin { flex-grow: 1; overflow-y: auto; padding: 32px 40px; }
        .admin-form-container { background-color: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; max-width: 600px; margin: 0 auto; padding: 32px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        
        .header-medico { display: flex; align-items: center; gap: 16px; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid #E2E8F0; }
        .header-medico i { font-size: 32px; color: #805AD5; background-color: #FAF5FF; padding: 16px; border-radius: 12px; }
        .header-medico h3 { margin: 0; color: #2D3748; }

        .grid-form { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .input-group-admin { margin-bottom: 16px; text-align: left; }
        .input-group-admin.full-width { grid-column: span 2; }
        .input-group-admin label { display: block; font-size: 12px; color: #718096; margin-bottom: 6px; font-weight: bold; text-transform: uppercase; }
        .input-group-admin input { width: 100%; padding: 12px 16px; border: 1px solid #CBD5E0; border-radius: 8px; box-sizing: border-box; font-size: 14px; outline: none; transition: 0.2s; }
        .input-group-admin input:focus { border-color: #12A388; }
        
        .radio-group { display: flex; gap: 16px; margin-top: 10px; }
        .btn-salvar-admin { background-color: #805AD5; color: white; border: none; width: 100%; padding: 14px; border-radius: 8px; font-size: 15px; font-weight: bold; cursor: pointer; margin-top: 24px; transition: 0.2s; }
        .btn-salvar-admin:hover { background-color: #6B46C1; }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
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
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Sair do sistema?');"><i class="fa-solid fa-arrow-right-from-bracket"></i> Sair</a>
    </aside>

    <main class="main-content">
        <header class="topbar-admin">
            <a href="admin-usuarios" class="btn-voltar"><i class="fa-solid fa-arrow-left"></i></a>
            <h2>Cadastrar Novo Médico</h2>
        </header>

        <div class="scroll-area-admin">
            <div class="admin-form-container">
                
                <div class="header-medico">
                    <i class="fa-solid fa-user-doctor"></i>
                    <div>
                        <h3>Perfil Médico</h3>
                        <p style="color: #718096; font-size: 13px; margin: 4px 0 0 0;">Crie as credenciais de acesso do novo profissional.</p>
                    </div>
                </div>

                <form action="admin-cadastro-medico" method="POST">
                    
                    <div class="grid-form">
                        <div class="input-group-admin">
                            <label>Nome</label>
                            <input type="text" name="nome_usuario" required>
                        </div>
                        <div class="input-group-admin">
                            <label>Sobrenome</label>
                            <input type="text" name="sobrenome_usuario" required>
                        </div>
                    </div>

                    <div class="grid-form">
                        <div class="input-group-admin">
                            <label>CPF</label>
                            <input type="text" name="cpf_usuario" maxlength="11" required>
                        </div>
                        <div class="input-group-admin">
                            <label>Data de Nascimento</label>
                            <input type="date" name="data_nascimento_usuario" required>
                        </div>
                    </div>

                    <div class="grid-form">
                        <div class="input-group-admin">
                            <label>Sexo</label>
                            <div class="radio-group">
                                <label><input type="radio" name="sexo_usuario" value="MASCULINO" required> Masculino</label>
                                <label><input type="radio" name="sexo_usuario" value="FEMININO" required> Feminino</label>
                            </div>
                        </div>
                        <div class="input-group-admin">
                            <label>CRM (Registro Médico)</label>
                            <input type="text" name="crm_usuario" placeholder="Ex: 123456-SP" required>
                        </div>
                    </div>

                    <div class="input-group-admin full-width">
                        <label>E-mail (Login)</label>
                        <input type="email" name="email_usuario" required>
                    </div>

                    <div class="input-group-admin full-width">
                        <label>Senha de Acesso Temporária</label>
                        <input type="password" name="senha_usuario" required>
                    </div>

                    <button type="submit" class="btn-salvar-admin">Cadastrar Médico no Sistema</button>
                </form>

            </div>
        </div>
    </main>
</div>

</body>
</html>