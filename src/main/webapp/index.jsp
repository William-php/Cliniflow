<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Login</title>
    <!-- Ligando o HTML ao nosso arquivo CSS -->
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <div class="login-container">
        <div class="logo-box">+</div>
        <h2>Clini<span style="color: #12A388;">Flow</span></h2>
        <p>Sua saúde fluindo.</p>

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
            Não tem uma conta? <a href="cadastro.html" class="register-link">Cadastre-se</a>
        </div>
    </div>

</body>
</html>