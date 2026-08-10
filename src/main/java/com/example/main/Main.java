package com.example.main;

import java.time.LocalDateTime;
import java.util.ArrayList;

import com.example.main.dao.UsuarioDAO;
import com.example.main.enums.Sexo;
import com.example.main.enums.StatusUsuario;
import com.example.main.models.Usuario;

public class Main {

	public static void main(String[] args) throws Exception {
		// TODO Auto-generated method stub
		
//		Usuario u = new Usuario(
//				"Marina",
//				"Silva",
//				LocalDateTime.parse("2000-12-03T10:15:30"),
//				"00012345633",
//				"marina@email.com",
//				"1234",
//				StatusUsuario.ATIVO,
//				Sexo.MASCULINO,
//				true,
//				"741852-BA"
//				);
//		UsuarioDAO.postUsuario(u);
		UsuarioDAO.deleteUsuarioById(5);
	}
	
	

}
