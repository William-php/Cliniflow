<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String erro = request.getParameter("erro");
    String conta = request.getParameter("conta");
%>
<!DOCTYPE html>
<html lang="pt-BR">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>CliniFlow - Login</title>
	    <link rel="stylesheet" href="css/style.css">
	    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
	</head>
	<body>
	
	    <div class="login-container">
	        <div class="logo-box">
	            <i class="fa-solid fa-plus"></i>
	        </div>
	        <h2>Clini<span style="color: #12A388;">Flow</span></h2>
	        <p>Sua saúde fluindo.</p>
	
	        <% if ("credenciais".equals(erro)) { %>
	            <div class="alert-login">E-mail ou senha incorretos.</div>
	        <% } else if ("conta_inativa".equals(erro)) { %>
	            <div class="alert-login">Esta conta foi desativada pelo usuário.</div>
	        <% } else if ("desativada".equals(conta)) { %>
	            <div class="alert-success">Sua conta foi excluída com sucesso.</div>
	        <% } %>
	
	        <form action="login" method="POST">
	            <div class="input-group">
	                <label>Login</label>
	                <input type="email" name="email_usuario" placeholder="joao@email.com" required>
	            </div>
	            
	            <div class="input-group">
	                <label>Senha</label>
	                <input type="password" name="senha_usuario" placeholder="Senha" required>
	            </div>
	            
	            <a href="#" class="forgot-password">Esqueci Minha senha</a>
	            
	            <button type="submit" class="btn-main">ENTRAR</button>
	        </form>
	        
	        <div class="register-container">
	            Não tem uma conta? <a href="cadastro" class="register-link">Cadastre-se</a>
	        </div>
	    </div>
	
	</body>
</html>