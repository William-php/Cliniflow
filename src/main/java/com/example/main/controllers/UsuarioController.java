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

@WebServlet(name = "usuario", urlPatterns = "/usuario")
public class UsuarioController extends HttpServlet {
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil perfil = (Perfil) session.getAttribute("usuarioLogado");
		
		boolean sucesso = atualizarUsuario(request, response);
		
		if (sucesso) {
			if (perfil != null && perfil.getUsuario() != null && perfil.getUsuario().isAdmUsuario()) {
				response.sendRedirect("admin-home?atualizado=true");
			} else {
				response.sendRedirect("home?atualizado=true");
			}
		} else {
			response.sendRedirect("editar-perfil?erro=falha_atualizar");
		}
	}
	
	public static boolean atualizarUsuario(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		Perfil perfil = (Perfil) session.getAttribute("usuarioLogado");
		
		try {
			Usuario usuarioAtualizado = removerUsuarioPerfil(perfil);
			
			// dados comuns a todos os perfis
			usuarioAtualizado.setNomeUsuario(request.getParameter("nome_usuario"));
			usuarioAtualizado.setSobrenomeUsuario(request.getParameter("sobrenome_usuario"));
			usuarioAtualizado.setEmailUsuario(request.getParameter("email_usuario"));
			
			// dados editáveis so pelo Adm
			String cpf = request.getParameter("cpf_usuario");
			if (cpf != null && !cpf.trim().isEmpty()) {
				usuarioAtualizado.setCpfUsuario(cpf);
			}
			
			String dataString = request.getParameter("data_nascimento_usuario");
			if (dataString != null && !dataString.isEmpty()) {
				java.time.LocalDateTime dataConvertida = java.time.LocalDate.parse(dataString).atStartOfDay();
				usuarioAtualizado.setDataNascimentoUsuario(dataConvertida);
			}
			
			String sexoParam = request.getParameter("sexo_usuario");
			if (sexoParam != null && !sexoParam.trim().isEmpty()) {
				usuarioAtualizado.setSexoUsuario(com.example.main.enums.Sexo.valueOf(sexoParam.toUpperCase()));
			}
			
			int responseBD = UsuarioDAO.putUsuarioById(usuarioAtualizado);
			
			if (responseBD != 0) {
				perfil.setUsuario(usuarioAtualizado);
				session.setAttribute("usuarioLogado", perfil);
				return true; 
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return false; 
	}
	
	public static Usuario removerUsuarioPerfil(Perfil p) throws Exception {
		Usuario usuario = p.getUsuario();
		if (usuario == null) throw new Exception();
		return usuario;
	}
}