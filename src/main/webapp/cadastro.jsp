<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CliniFlow - Cadastro de Paciente</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #F7FAFC; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; padding: 40px 20px; box-sizing: border-box; }
        .cadastro-card { background-color: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 16px; padding: 40px; max-width: 540px; width: 100%; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .logo-box { width: 64px; height: 64px; background-color: #12A388; border-radius: 16px; display: flex; justify-content: center; align-items: center; margin: 0 auto 16px auto; color: #FFFFFF; font-size: 28px; }
        .cadastro-header { text-align: center; margin-bottom: 32px; }
        .cadastro-header h2 { margin: 0 0 8px 0; color: #2D3748; }
        .cadastro-header p { margin: 0; color: #718096; font-size: 14px; }
        .grid-form { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px; }
        .input-group label { display: block; font-size: 12px; color: #718096; margin-bottom: 6px; font-weight: bold; text-transform: uppercase; }
        .input-group input { width: 100%; padding: 12px 16px; border: 1px solid #CBD5E0; border-radius: 8px; box-sizing: border-box; font-size: 14px; outline: none; transition: 0.2s; }
        .input-group input:focus { border-color: #12A388; }
        .radio-group { display: flex; gap: 16px; margin-top: 10px; }
        .btn-salvar { background-color: #12A388; color: white; border: none; width: 100%; padding: 14px; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; margin-top: 16px; transition: 0.2s; }
        .btn-salvar:hover { background-color: #0e826c; }
        .link-voltar { display: block; text-align: center; margin-top: 24px; color: #A0AEC0; text-decoration: none; font-size: 14px; }
        .link-voltar:hover { color: #2D3748; }
    </style>
</head>
<body>

    <div class="cadastro-card">
        <div class="cadastro-header">
            <div class="logo-box"><i class="fa-solid fa-plus"></i></div>
            <h2>Criar sua Conta</h2>
            <p>Junte-se ao CliniFlow e tenha sua saúde em suas mãos.</p>
        </div>

        <form action="cadastro" method="POST">
            <div class="grid-form">
                <div class="input-group">
                    <label>Nome</label>
                    <input type="text" name="nome_usuario" required>
                </div>
                <div class="input-group">
                    <label>Sobrenome</label>
                    <input type="text" name="sobrenome_usuario" required>
                </div>
            </div>

            <div class="grid-form">
                <div class="input-group">
                    <label>CPF</label>
                    <input type="text" name="cpf_usuario" maxlength="11" required>
                </div>
                <div class="input-group">
                    <label>Data de Nascimento</label>
                    <input type="date" name="data_nascimento_usuario" required>
                </div>
            </div>

            <div class="input-group" style="margin-bottom: 16px;">
                <label>Sexo</label>
                <div class="radio-group">
                    <label><input type="radio" name="sexo_usuario" value="MASCULINO" required> Masculino</label>
                    <label><input type="radio" name="sexo_usuario" value="FEMININO" required> Feminino</label>
                </div>
            </div>

            <div class="input-group" style="margin-bottom: 16px;">
                <label>E-mail</label>
                <input type="email" name="email_usuario" required>
            </div>

            <div class="input-group" style="margin-bottom: 16px;">
                <label>Senha</label>
                <input type="password" name="senha_usuario" required>
            </div>

            <button type="submit" class="btn-salvar">Cadastrar Paciente</button>
        </form>
        
        <a href="index.jsp" class="link-voltar">Já tenho uma conta. Voltar para o Login.</a>
    </div>

</body>
</html>