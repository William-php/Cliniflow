<%@page import="com.example.main.models.Perfil"%>
<%@page import="com.example.main.models.Usuario"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null || usuarioLogado.getUsuario() == null || !usuarioLogado.getUsuario().isAdmUsuario()) {
        response.sendRedirect("index.jsp");
        return;
    }

    Usuario usr = usuarioLogado.getUsuario();
    String nomeAdmin = usr.getNomeUsuario() != null ? usr.getNomeUsuario() : "Administrador";
    String sobrenomeAdmin = usr.getSobrenomeUsuario() != null ? usr.getSobrenomeUsuario() : "";
    String nomeCompleto = (nomeAdmin + " " + sobrenomeAdmin).trim();

    // Leitura do parâmetro de feedback de atualização
    String atualizado = request.getParameter("atualizado");

    Integer totalPacientes = (Integer) request.getAttribute("totalPacientes");
    Integer totalMedicos = (Integer) request.getAttribute("totalMedicos");
    Integer consultasHoje = (Integer) request.getAttribute("consultasHoje");
    Integer listasEsperaAtivas = (Integer) request.getAttribute("listasEsperaAtivas");

    int qtdPacientes = totalPacientes != null ? totalPacientes : 0;
    int qtdMedicos = totalMedicos != null ? totalMedicos : 0;
    int qtdConsultasHoje = consultasHoje != null ? consultasHoje : 0;
    int qtdListasEspera = listasEsperaAtivas != null ? listasEsperaAtivas : 0;
%>

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Painel do Administrador</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* =========================================================================
           ESTILOS DO PAINEL ADMIN (Recortar e colar no style.css se preferir)
           ========================================================================= */
        body.home-body, .dashboard-layout { height: 100vh; overflow: hidden; margin: 0; }
        .main-content { display: flex; flex-direction: column; height: 100vh; overflow: hidden; background-color: #F7FAFC; }
        
        /* CABEÇALHO VERDE PADRÃO CLIFLOW */
        .topbar-admin {
            background-color: #12A388;
            padding: 28px 40px;
            color: #FFFFFF;
            flex-shrink: 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .topbar-admin-user p {
            font-size: 13px;
            color: #E6FFFA;
            margin: 0 0 4px 0;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 600;
        }
        .topbar-admin-user h3 {
            font-size: 22px;
            margin: 0;
            font-weight: 700;
        }

        /* ÁREA COM ROLAGEM EXCLUSIVA */
        .scroll-area-admin {
            flex-grow: 1;
            overflow-y: auto;
            overflow-x: hidden;
            padding: 32px 40px 40px 40px;
            min-height: 0;
        }
        .scroll-area-admin::-webkit-scrollbar { width: 6px; }
        .scroll-area-admin::-webkit-scrollbar-thumb { background-color: #CBD5E0; border-radius: 4px; }

        /* GRID DE 4 CARDS DE ESTATÍSTICAS */
        .admin-metrics-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 36px;
        }
        .metric-card {
            border-radius: 12px;
            padding: 20px 24px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            border: 1px solid transparent;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .metric-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.04);
        }
        .metric-card h2 {
            font-size: 28px;
            margin: 0 0 4px 0;
            font-weight: 800;
        }
        .metric-card p {
            font-size: 13px;
            margin: 0;
            color: #718096;
            font-weight: 600;
        }

        /* CORES ESPECÍFICAS DOS CARDS CONFORME DESIGN SYSTEM */
        .card-pacientes { background-color: #E6FFFA; border-color: #B2F5EA; }
        .card-pacientes h2 { color: #12A388; }

        .card-medicos { background-color: #FAF5FF; border-color: #E9D8FD; }
        .card-medicos h2 { color: #805AD5; }

        .card-consultas { background-color: #F0FFF4; border-color: #C6F6D5; }
        .card-consultas h2 { color: #38A169; }

        .card-espera { background-color: #FFFDF5; border-color: #FEEBC8; }
        .card-espera h2 { color: #DD6B20; }

        /* SEÇÃO DE GERENCIAMENTO */
        .admin-section-title {
            font-size: 18px;
            font-weight: 700;
            color: #2D3748;
            margin: 0 0 16px 0;
        }

        .management-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .management-card {
            background-color: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 18px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            text-decoration: none;
            transition: border-color 0.2s, box-shadow 0.2s;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
        }
        .management-card:hover {
            border-color: #12A388;
            box-shadow: 0 4px 10px rgba(18, 163, 136, 0.08);
        }

        .management-info {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .management-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            background-color: #F7FAFC;
            border: 1px solid #EDF2F7;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 18px;
            color: #4A5568;
        }

        .management-text h4 {
            margin: 0 0 4px 0;
            font-size: 15px;
            font-weight: 700;
            color: #2D3748;
        }
        .management-text p {
            margin: 0;
            font-size: 13px;
            color: #A0AEC0;
        }

        .management-chevron {
            color: #CBD5E0;
            font-size: 14px;
            transition: transform 0.2s, color 0.2s;
        }
        .management-card:hover .management-chevron {
            color: #12A388;
            transform: translateX(4px);
        }

        /* NOTIFICAÇÃO FLUTUANTE (TOAST) */
        .toast-sucesso {
            position: fixed;
            top: 24px;
            right: 40px;
            background-color: #E6FFFA;
            color: #12A388;
            padding: 16px 24px;
            border-radius: 8px;
            border: 1px solid #12A388;
            font-size: 14px;
            font-weight: bold;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 24px;
            z-index: 9999;
            transition: opacity 0.3s ease;
        }
        .toast-conteudo { display: flex; align-items: center; gap: 12px; }
        .toast-fechar { cursor: pointer; color: #12A388; font-size: 18px; transition: 0.2s; }
        .toast-fechar:hover { color: #0e826c; }

        @media (max-width: 1024px) {
            .admin-metrics-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        /* ========================================================================= */
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <!-- BARRA LATERAL ADMINISTRATIVA -->
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="admin-home" class="nav-item active"><i class="fa-solid fa-house"></i> Início</a>
            <a href="admin-usuarios" class="nav-item"><i class="fa-solid fa-users"></i> Usuários</a>
            <a href="admin-consultas" class="nav-item"><i class="fa-solid fa-calendar-check"></i> Consultas</a>
            <a href="admin-agendas" class="nav-item"><i class="fa-solid fa-calendar-plus"></i> Agendas Médicas</a>
            <a href="admin-listas-espera" class="nav-item"><i class="fa-solid fa-hourglass-half"></i> Listas de Espera</a>
            <a href="editar-perfil" class="nav-item"><i class="fa-solid fa-user"></i> Meu Perfil</a>
            <a href="#" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
        </ul>
        <a href="/cliniflow/" class="nav-item" style="margin-bottom: 24px; color: #E53E3E;" onclick="return confirm('Tem certeza que deseja sair do sistema?');">
            <i class="fa-solid fa-arrow-right-from-bracket"></i> Sair
        </a>
    </aside>

    <!-- ÁREA PRINCIPAL -->
    <main class="main-content">
        
        <!-- MENSAGEM FLUTUANTE DE DADOS ATUALIZADOS -->
        <% if ("true".equals(atualizado)) { %>
            <div id="toast-alerta" class="toast-sucesso">
                <div class="toast-conteudo">
                    <i class="fa-solid fa-circle-check"></i> 
                    <span>Perfil atualizado com sucesso!</span>
                </div>
                <i class="fa-solid fa-xmark toast-fechar" onclick="fecharToast()"></i>
            </div>

            <script>
                setTimeout(fecharToast, 4000);

                function fecharToast() {
                    var toast = document.getElementById("toast-alerta");
                    if(toast) {
                        toast.style.opacity = "0";
                        setTimeout(() => toast.remove(), 300);
                    }
                }
            </script>
        <% } %>

        <!-- CABEÇALHO VERDE CLÍNIFLOW -->
        <header class="topbar-admin">
            <div class="topbar-admin-user">
                <p>Administração</p>
                <h3><%= nomeCompleto %></h3>
            </div>
            <i class="fa-regular fa-bell" style="font-size: 22px; color: #FFFFFF; cursor: pointer;"></i>
        </header>

        <!-- CONTAINER COM ROLAGEM -->
        <div class="scroll-area-admin">
            
            <!-- GRID DOS 4 CARDS DE INDICADORES -->
            <div class="admin-metrics-grid">
                <div class="metric-card card-pacientes">
                    <h2><%= qtdPacientes %></h2>
                    <p>Pacientes</p>
                </div>
                <div class="metric-card card-medicos">
                    <h2><%= qtdMedicos %></h2>
                    <p>Médicos</p>
                </div>
                <div class="metric-card card-consultas">
                    <h2><%= qtdConsultasHoje %></h2>
                    <p>Consultas hoje</p>
                </div>
                <div class="metric-card card-espera">
                    <h2><%= qtdListasEspera %></h2>
                    <p>Listas de espera</p>
                </div>
            </div>

            <!-- SEÇÃO DE GERENCIAMENTO -->
            <h3 class="admin-section-title">Gerenciar</h3>

            <div class="management-list">
                
                <!-- Card Usuários -->
                <a href="admin-usuarios" class="management-card">
                    <div class="management-info">
                        <div class="management-icon">
                            <i class="fa-solid fa-users"></i>
                        </div>
                        <div class="management-text">
                            <h4>Usuários</h4>
                            <p>Gerenciar pacientes e médicos</p>
                        </div>
                    </div>
                    <i class="fa-solid fa-chevron-right management-chevron"></i>
                </a>

                <!-- Card Gerenciar Consultas -->
                <a href="admin-consultas" class="management-card">
                    <div class="management-info">
                        <div class="management-icon">
                            <i class="fa-solid fa-calendar-check"></i>
                        </div>
                        <div class="management-text">
                            <h4>Consultas</h4>
                            <p>Todas as consultas do sistema</p>
                        </div>
                    </div>
                    <i class="fa-solid fa-chevron-right management-chevron"></i>
                </a>

                <!-- Card Agendas Médicas -->
                <a href="admin-agendas" class="management-card">
                    <div class="management-info">
                        <div class="management-icon">
                            <i class="fa-solid fa-calendar-plus"></i>
                        </div>
                        <div class="management-text">
                            <h4>Agendas Médicas</h4>
                            <p>Definir horários de atendimento</p>
                        </div>
                    </div>
                    <i class="fa-solid fa-chevron-right management-chevron"></i>
                </a>

                <!-- Card Listas de Espera -->
                <a href="admin-listas-espera" class="management-card">
                    <div class="management-info">
                        <div class="management-icon">
                            <i class="fa-solid fa-hourglass-half"></i>
                        </div>
                        <div class="management-text">
                            <h4>Listas de Espera</h4>
                            <p>Filas ativas no sistema</p>
                        </div>
                    </div>
                    <i class="fa-solid fa-chevron-right management-chevron"></i>
                </a>

            </div>

        </div>
    </main>
</div>

</body>
</html>