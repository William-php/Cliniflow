package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashSet;

import com.example.main.models.ListaEspera;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;
import com.example.main.utils.Conexao;
import com.example.main.utils.Utilidade;

public class ListaEsperaDAO {
	public static HashSet<ListaEspera> getListaEsperaByConsulta(int idConsulta) throws Exception {
		Connection conexao = Conexao.conectar();
		
		String sql = "SELECT listas_espera.*, "
				+ "perfis.*, "
				+ "usuarios.* "
				+ "FROM listas_espera "
				+ "JOIN perfis ON listas_espera.paciente = perfis.id_perfil "
				+ "JOIN usuarios ON perfis.usuario = usuarios.id_usuario "
				+ "WHERE listas_espera.consulta = ?";
		
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setInt(1, idConsulta);
		
		ResultSet rs = stmt.executeQuery();
		HashSet<ListaEspera> listaEspera = new HashSet<ListaEspera>(); 
		if (rs.next()) {
			Usuario u = Utilidade.gerarUsuarioComDadosDoBD(rs);
			Perfil p = Utilidade.gerarPerfilComDadosDoBD(rs);
			p.setUsuario(u);
			ListaEspera LE = Utilidade.gerarObjListaEsperaComDadosBD(rs);
			LE.setPacientesListaEspera(p);
			listaEspera.add(LE);
		}					
		return listaEspera;	
	}
	
	public static HashSet<ListaEspera> getListaEsperaByPaciente(int idPaciente) throws Exception {
		Connection conexao = Conexao.conectar();
		
		String sql = "SELECT "
				+ "    listas_espera.*, "
				+ "    perfis.*, "
				+ "    usuarios.*, "
				+ "    especialidades.*"
				+ "FROM listas_espera "
				+ "JOIN consultas ON consultas.id_consulta = listas_espera.consulta "
				+ "JOIN perfis ON perfis.id_perfil = consultas.medico "
				+ "JOIN usuarios ON usuarios.id_usuario = perfis.usuario "
				+ "JOIN especialidades_medico ON especialidades_medico.medico = perfis.id_perfil "
				+ "JOIN especialidades ON especialidades.id_especialidade = especialidades_medico.especialidade "
				+ "WHERE listas_espera.paciente = ? LIMIT 20";
		
		PreparedStatement stmt = conexao.prepareStatement(sql);
		stmt.setInt(1, idPaciente);
		HashSet<ListaEspera> listaEsperaPaciente = new HashSet<ListaEspera>();
		ResultSet rs = stmt.executeQuery();
		
		while (rs.next()) {
			Usuario u = Utilidade.gerarUsuarioComDadosDoBD(rs);
			Perfil p = Utilidade.gerarPerfilComDadosDoBD(rs);
			p.setUsuario(u);
			ListaEspera LE = Utilidade.gerarObjListaEsperaComDadosBD(rs);
			LE.setMedicoListaEspera(p);
			listaEsperaPaciente.add(LE);
		}
		
		return listaEsperaPaciente;
	}
}
