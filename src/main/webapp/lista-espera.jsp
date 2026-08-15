<%@page import="com.example.main.models.Perfil"%>
<%@page import="java.util.List"%>
<%
    // Simulação de validação de sessão
    Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
    if (usuarioLogado == null) {
        // response.sendRedirect("index.html");
        // return;
    }
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Lista de Espera</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* ESTILIZAÇÃO BASE */
        body { font-family: Arial, sans-serif; background-color: #F7FAFC; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        body.home-body { align-items: flex-start; }
        h2, h3, h4, p { margin: 0; }

        /* DASHBOARD WEB */
        .dashboard-layout { display: flex; width: 100vw; min-height: 100vh; background-color: #F4F7F6; }

        /* Sidebar - Adaptada para alinhar ao estilo do seu sistema */
        .sidebar { width: 250px; background-color: #FFFFFF; border-right: 1px solid #E2E8F0; display: flex; flex-direction: column; }
        .sidebar-logo { padding: 24px; font-size: 24px; font-weight: bold; color: #2D3748; text-align: center; border-bottom: 1px solid #E2E8F0; }
        .sidebar-logo span { color: #12A388; }
        .nav-menu { list-style: none; padding: 0; margin: 0; flex-grow: 1; }
        .nav-item { padding: 16px 24px; color: #718096; text-decoration: none; display: flex; align-items: center; font-weight: bold; border-left: 4px solid transparent; }
        .nav-item:hover, .nav-item.active { background-color: #E6FFFA; color: #12A388; border-left: 4px solid #12A388; }
        .nav-item i { margin-right: 12px; font-size: 18px; width: 24px; text-align: center; }

        /* Main Content */
        .main-content { flex-grow: 1; display: flex; flex-direction: column; min-height: 100vh; }
        
        /* Novo Topbar Simplificado (Fundo claro conforme a imagem) */
        .topbar-simple { background-color: transparent; padding: 24px 40px; display: flex; justify-content: space-between; align-items: center; }
        .page-title { display: flex; align-items: center; font-size: 20px; font-weight: bold; color: #2D3748; gap: 8px; text-decoration: none; }
        .page-title i { color: #12A388; font-size: 20px; }
        .topbar-actions i { font-size: 24px; color: #A0AEC0; cursor: pointer; }

        /* Subtítulo centralizado */
        .subtitle-area { text-align: center; margin: 20px 0 40px 0; }
        .subtitle-area p { color: #A0AEC0; font-size: 14px; }

        /* Container da Lista de Espera */
        .waitlist-container { padding: 0 40px; display: flex; flex-wrap: wrap; gap: 24px; justify-content: center; }

        /* Card da Fila de Espera */
        .card-espera { 
            background-color: #FFFFFF; 
            border: 1px solid #E2E8F0; 
            border-radius: 12px; 
            padding: 20px; 
            display: flex; 
            align-items: flex-start; 
            gap: 16px; 
            width: 100%; 
            max-width: 340px; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }
        
        /* Posição na Fila (Badge redonda) */
        .posicao-badge { 
            background-color: #E6FFFA; 
            color: #12A388; 
            font-weight: bold; 
            border-radius: 50%; 
            width: 40px; 
            height: 40px; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            font-size: 14px;
            flex-shrink: 0;
        }

        /* Informações do Médico */
        .info-medico { flex-grow: 1; }
        .info-medico h4 { color: #2D3748; font-size: 16px; margin-bottom: 4px; }
        .info-medico p { color: #A0AEC0; font-size: 12px; margin-bottom: 12px; }

        /* Ações do Card */
        .acoes-card { display: flex; align-items: center; gap: 16px; }
        .badge-status { background-color: #E6FFFA; color: #12A388; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        .btn-sair-fila { color: #FC8181; font-size: 12px; text-decoration: none; font-weight: bold; cursor: pointer; border: none; background: none; padding: 0; }
        .btn-sair-fila:hover { text-decoration: underline; color: #E53E3E; }
    </style>
</head>
<body class="home-body">

<div class="dashboard-layout">
    
    <!-- BARRA LATERAL -->
    <aside class="sidebar">
        <div class="sidebar-logo">Clini<span>Flow</span></div>
        <ul class="nav-menu">
            <a href="inicio.jsp" class="nav-item"><i class="fa-solid fa-house"></i> Início</a>
            <!-- Mantido ativo conforme a imagem -->
            <a href="minhas-consultas.jsp" class="nav-item active"><i class="fa-solid fa-notes-medical"></i> Minhas Consultas</a>
            <a href="perfil.jsp" class="nav-item"><i class="fa-solid fa-user"></i> Perfil</a>
            <a href="ajuda.jsp" class="nav-item"><i class="fa-solid fa-circle-question"></i> Ajuda</a>
        </ul>
        <a href="logout.jsp" class="nav-item" style="margin-bottom: 24px; color: #A0AEC0;">
            <i class="fa-solid fa-arrow-right-from-bracket"></i> Sair
        </a>
    </aside>

    <!-- ÁREA PRINCIPAL -->
    <main class="main-content">
        
        <!-- CABEÇALHO SIMPLIFICADO -->
        <header class="topbar-simple">
            <a href="voltar.jsp" class="page-title">
                <i class="fa-solid fa-chevron-left"></i> Lista de Espera
            </a>
            <div class="topbar-actions">
                <i class="fa-regular fa-bell"></i>
            </div>
        </header>

        <!-- SUBTÍTULO -->
        <div class="subtitle-area">
            <p>Você será notificado quando uma vaga abrir.</p>
        </div>

        <!-- GRID DE LISTA DE ESPERA -->
        <div class="waitlist-container">
            
            <%-- Exemplo de laço de repetição caso venha do backend
                 List<Espera> filaEspera = (List<Espera>) request.getAttribute("filaEspera");
                 if (filaEspera != null && !filaEspera.isEmpty()) {
                     for (Espera e : filaEspera) {
            --%>

            <!-- Card Estático 1 -->
            <div class="card-espera">
                <div class="posicao-badge">#1</div>
                <div class="info-medico">
                    <h4>Dr. João Silva</h4>
                    <p>Ortopedista - 25/05, 09:00</p>
                    <div class="acoes-card">
                        <span class="badge-status">Na fila</span>
                        <button class="btn-sair-fila" onclick="confirmarSaida(1)">Sair da fila</button>
                    </div>
                </div>
            </div>

            <!-- Card Estático 2 -->
            <div class="card-espera">
                <div class="posicao-badge">#3</div>
                <div class="info-medico">
                    <h4>Dr. Manuel Gomes</h4>
                    <p>Ortopedista - 28/05, 11:00</p>
                    <div class="acoes-card">
                        <span class="badge-status">Na fila</span>
                        <button class="btn-sair-fila" onclick="confirmarSaida(3)">Sair da fila</button>
                    </div>
                </div>
            </div>

            <%-- 
                     }
                 } else {
                     out.print("<p style='color: #A0AEC0;'>Você não está em nenhuma lista de espera no momento.</p>");
                 }
            --%>

        </div>
    </main>
</div>

<script>
    function confirmarSaida(idFila) {
        if(confirm("Tem certeza que deseja sair desta fila de espera?")) {
            // Lógica para chamar o backend e remover da fila
            // window.location.href = "removerFila?id=" + idFila;
            console.log("Removendo da fila: " + idFila);
        }
    }
</script>

</body>
</html>