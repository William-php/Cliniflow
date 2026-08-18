<%@page import="com.example.main.models.Perfil"%>
<%@page import="com.example.main.models.Usuario"%>
<%@page import="com.example.main.models.Especialidade"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Perfil adminLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (adminLogado == null || adminLogado.getUsuario() == null || !adminLogado.getUsuario().isAdmUsuario()) {
        response.sendRedirect("index.jsp");
        return;
    }

    Usuario usrEdit = (Usuario) request.getAttribute("usuarioEdit");
    if (usrEdit == null) {
        response.sendRedirect("admin-usuarios");
        return;
    }

    String nome = usrEdit.getNomeUsuario() != null ? usrEdit.getNomeUsuario() : "";
    String sobrenome = usrEdit.getSobrenomeUsuario() != null ? usrEdit.getSobrenomeUsuario() : "";
    String email = usrEdit.getEmailUsuario() != null ? usrEdit.getEmailUsuario() : "";
    String cpf = usrEdit.getCpfUsuario() != null ? usrEdit.getCpfUsuario() : "";
    String crm = usrEdit.getCrmUsuario() != null ? usrEdit.getCrmUsuario() : "";
    String statusAtual = usrEdit.getStatusUsuario() != null ? usrEdit.getStatusUsuario().name() : "DESATIVADO";
    String sexoAtual = usrEdit.getSexoUsuario() != null ? usrEdit.getSexoUsuario().name() : "";
    
    Integer idPerfilEdit = (Integer) request.getAttribute("idPerfilEdit");
    String tipoPerfilEdit = (String) request.getAttribute("tipoPerfilEdit");
    
    // Verificação dupla: se tiver CRM preenchido OU se o perfil for MEDICO
    boolean isMedico = (crm != null && !crm.trim().isEmpty()) || "MEDICO".equalsIgnoreCase(tipoPerfilEdit);

    String dataNascimento = "";
    if (usrEdit.getDataNascimentoUsuario() != null) {
        DateTimeFormatter htmlFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        dataNascimento = usrEdit.getDataNascimentoUsuario().format(htmlFormatter);
    }

    String inicialNome = !nome.isEmpty() ? nome.substring(0, 1).toUpperCase() : "U";
    String inicialSobrenome = !sobrenome.isEmpty() ? sobrenome.substring(0, 1).toUpperCase() : "";
    String iniciais = inicialNome + inicialSobrenome;
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Editar Usuário (Admin)</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body.home-body, .dashboard-layout { height: 100vh; overflow: hidden; margin: 0; }
        .main-content { display: flex; flex-direction: column; height: 100vh; overflow: hidden; background-color: #F7FAFC; }
        
        .topbar-admin { background-color: #12A388; padding: 24px 40px; color: #FFFFFF; flex-shrink: 0; display: flex; align-items: center; }
        .topbar-admin h2 { font-size: 22px; margin: 0; font-weight: 700; }

        .scroll-area-admin { flex-grow: 1; overflow-y: auto; overflow-x: hidden; padding: 32px 40px; min-height: 0; }
        .scroll-area-admin::-webkit-scrollbar { width: 6px; }
        .scroll-area-admin::-webkit-scrollbar-thumb { background-color: #CBD5E0; border-radius: 4px; }

        .admin-form-container { background-color: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; max-width: 600px; margin: 0 auto; padding: 32px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        
        .user-header-edit { display: flex; flex-direction: column; align-items: center; text-align: center; gap: 12px; margin-bottom: 32px; padding-bottom: 24px; border-bottom: 1px solid #E2E8F0; }
        .avatar-circle { width: 88px; height: 88px; border-radius: 50%; border: 3px solid #12A388; display: flex; justify-content: center; align-items: center; font-size: 32px; font-weight: bold; color: #12A388; background-color: #E6FFFA; }
        .user-header-info h3 { margin: 0; color: #2D3748; font-size: 22px; }

        .grid-form { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .input-group-admin { margin-bottom: 16px; text-align: left; }
        .input-group-admin.full-width { grid-column: span 2; }
        .input-group-admin label { display: block; font-size: 12px; color: #718096; margin-bottom: 6px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; }
        .input-group-admin input, .input-group-admin select { width: 100%; padding: 12px 16px; border: 1px solid #CBD5E0; border-radius: 8px; box-sizing: border-box; font-size: 14px; color: #2D3748; background-color: #FFFFFF; outline: none; transition: border-color 0.2s; }
        .input-group-admin input:focus, .input-group-admin select:focus { border-color: #12A388; box-shadow: 0 0 0 3px rgba(18, 163, 136, 0.1); }
        
        .radio-group { display: flex; gap: 16px; margin-top: 8px; }
        .radio-label { display: flex; align-items: center; gap: 8px; font-size: 14px; color: #2D3748; cursor: pointer; }
        .radio-label input[type="radio"] { width: 18px; height: 18px; margin: 0; cursor: pointer; accent-color: #12A388; }

        .btn-salvar-admin { background-color: #12A388; color: white; border: none; width: 100%; padding: 14px; border-radius: 8px; font-size: 15px; font-weight: bold; cursor: pointer; margin-top: 24px; transition: 0.2s; }
        .btn-salvar-admin:hover { background-color: #0e826c; }
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
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Tem certeza que deseja sair do sistema?');">
            <i class="fa-solid fa-arrow-right-from-bracket"></i> Sair
        </a>
    </aside>

    <main class="main-content">
        <header class="topbar-admin">
            <h2>Editar Usuário</h2>
        </header>

        <div class="scroll-area-admin">
            <div class="admin-form-container">
                
                <div class="user-header-edit">
                    <div class="avatar-circle"><%= iniciais %></div>
                    <div class="user-header-info">
                        <h3><%= nome %> <%= sobrenome %></h3>
                    </div>
                </div>

                <form action="admin-editar-usuario" method="POST">
                    <input type="hidden" name="id_usuario" value="<%= usrEdit.getIdUsuario() %>">
                    <input type="hidden" name="id_perfil" value="<%= idPerfilEdit != null ? idPerfilEdit : 0 %>">
                    
                    <div class="grid-form">
                        <div class="input-group-admin">
                            <label>Nome</label>
                            <input type="text" name="nome_usuario" value="<%= nome %>" required>
                        </div>

                        <div class="input-group-admin">
                            <label>Sobrenome</label>
                            <input type="text" name="sobrenome_usuario" value="<%= sobrenome %>" required>
                        </div>
                    </div>

                    <div class="grid-form">
                        <div class="input-group-admin">
                            <label>CPF</label>
                            <input type="text" name="cpf_usuario" value="<%= cpf %>" required>
                        </div>

                        <div class="input-group-admin">
                            <label>Data de Nascimento</label>
                            <input type="date" name="data_nascimento_usuario" value="<%= dataNascimento %>" required>
                        </div>
                    </div>

                    <div class="grid-form">
                        <div class="input-group-admin">
                            <label>Sexo</label>
                            <div class="radio-group">
                                <label class="radio-label">
                                    <input type="radio" name="sexo_usuario" value="MASCULINO" <%= "MASCULINO".equalsIgnoreCase(sexoAtual) ? "checked" : "" %> required>
                                    Masculino
                                </label>
                                <label class="radio-label">
                                    <input type="radio" name="sexo_usuario" value="FEMININO" <%= "FEMININO".equalsIgnoreCase(sexoAtual) ? "checked" : "" %> required>
                                    Feminino
                                </label>
                            </div>
                        </div>

                        <div class="input-group-admin">
                            <label>Status da Conta</label>
                            <select name="status_usuario">
                                <option value="ATIVO" <%= "ATIVO".equalsIgnoreCase(statusAtual) ? "selected" : "" %>>Conta Ativa</option>
                                <option value="DESATIVADO" <%= "DESATIVADO".equalsIgnoreCase(statusAtual) ? "selected" : "" %>>Conta Desativada / Bloqueada</option>
                            </select>
                        </div>
                    </div>

                    <% if (isMedico) { %>
                        <div class="input-group-admin full-width">
                            <label>CRM (Registro Médico)</label>
                            <input type="text" name="crm_usuario" value="<%= crm %>" placeholder="Ex: 123456-SP" required>
                        </div>
                        
                        <div class="input-group-admin full-width">
                            <label>Especialidades Atendidas (Tipo)</label>
                            <div class="checkbox-group" style="display: flex; gap: 16px; flex-wrap: wrap; margin-top: 8px; background-color: #F7FAFC; padding: 16px; border-radius: 8px; border: 1px solid #E2E8F0;">
                                <%
                                    HashSet<Especialidade> todasEsp = (HashSet<Especialidade>) request.getAttribute("listaEspecialidades");
                                    List<Integer> vinculadas = (List<Integer>) request.getAttribute("especialidadesVinculadas");
                                    
                                    if (todasEsp != null && !todasEsp.isEmpty()) {
                                        for (Especialidade e : todasEsp) {
                                            boolean checked = vinculadas != null && vinculadas.contains(e.getIdEspecialidade());
                                            String nomeExibicao = e.getTipoEspecialidade() != null ? e.getTipoEspecialidade().name() : "INDEFINIDA";
                                %>
                                <label style="display: flex; align-items: center; gap: 8px; font-weight: normal; text-transform: none; font-size: 14px; color: #2D3748; cursor: pointer;">
                                    <input type="checkbox" name="especialidades_medico" value="<%= e.getIdEspecialidade() %>" <%= checked ? "checked" : "" %> style="width: 18px; height: 18px; accent-color: #12A388;">
                                    <%= nomeExibicao %>
                                </label>
                                <%      }
                                    } else {
                                %>
                                <span style="color: #A0AEC0; font-size: 13px;">Nenhuma especialidade cadastrada no banco de dados.</span>
                                <% } %>
                            </div>
                        </div>
                    <% } %>

                    <div class="input-group-admin full-width">
                        <label>E-mail</label>
                        <input type="email" name="email_usuario" value="<%= email %>" required>
                    </div>

                    <button type="submit" class="btn-salvar-admin">Salvar Alterações</button>
                </form>

            </div>
        </div>
    </main>
</div>

</body>
</html>