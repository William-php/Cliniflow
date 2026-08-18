package com.example.main.controllers;

import java.io.IOException;

import com.example.main.dao.UsuarioDAO;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "adminCadastroPaciente", urlPatterns = {"/admin-cadastro-paciente"})
public class AdminCadastroPacienteController extends HttpServlet {
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil usuarioLogado = (Perfil) session.getAttribute("usuarioLogado");
		
		if (usuarioLogado != null && usuarioLogado.getUsuario() != null && usuarioLogado.getUsuario().isAdmUsuario()) {
			request.getRequestDispatcher("admin-cadastro-paciente.jsp").forward(request, response);
		} else {
			response.sendRedirect("index.jsp");
		}
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			Usuario u = new Usuario();
			u.setNomeUsuario(request.getParameter("nome_usuario"));
			u.setSobrenomeUsuario(request.getParameter("sobrenome_usuario"));
			u.setCpfUsuario(request.getParameter("cpf_usuario"));
			u.setEmailUsuario(request.getParameter("email_usuario"));
			u.setSenhaUsuario(request.getParameter("senha_usuario")); 
			
			String dataString = request.getParameter("data_nascimento_usuario");
			u.setDataNascimentoUsuario(java.time.LocalDate.parse(dataString).atStartOfDay());
			
			String sexoParam = request.getParameter("sexo_usuario");
			u.setSexoUsuario(com.example.main.enums.Sexo.valueOf(sexoParam.toUpperCase()));
			
			u.setStatusUsuario(com.example.main.enums.StatusUsuario.ATIVO);
			u.setAdmUsuario(false);
			
			Perfil p = new Perfil();
			p.setTipoPerfil(com.example.main.enums.TipoPerfil.PACIENTE);
			
			UsuarioDAO.postUsuario(u, p);
			
			response.sendRedirect("admin-usuarios?sucesso=paciente");
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("admin-cadastro-paciente?erro=falha");
		}
	}
}