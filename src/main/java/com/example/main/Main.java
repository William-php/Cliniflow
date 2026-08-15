package com.example.main;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;

import com.example.main.dao.EspecialidadeDAO;
import com.example.main.dao.UsuarioDAO;
import com.example.main.enums.Sexo;
import com.example.main.enums.StatusUsuario;
import com.example.main.enums.TipoPerfil;
import com.example.main.models.Especialidade;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;

public class Main {

	public static void main(String[] args) throws Exception {
		// TODO Auto-generated method stub
		
		Usuario u = new Usuario(				
				"Chico",
				"Sadoc",
				LocalDateTime.parse("2000-12-03T10:15:30"),
				"00012305643",
				"rsadoc1@email.com",
				"1234",
				StatusUsuario.ATIVO,
				Sexo.MASCULINO,
				true,
				"741850-BA"
				);
		Perfil perfil = new Perfil(TipoPerfil.MEDICO);
		
		UsuarioDAO.postUsuario(u, perfil);
		//UsuarioDAO.deleteUsuarioById(5);
		
//		HashSet<Especialidade> especialidades = EspecialidadeDAO.getEspecialidades();
//		for (Especialidade e:especialidades) {
//			System.out.println(e.getTipoEspecialidade().name() + " - " + e.getNomeEspecialidade());
//		}
	}
	
	

}
