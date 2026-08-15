package com.example.main.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashSet;

import com.example.main.models.Consulta;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;
import com.example.main.utils.Conexao;
import com.example.main.utils.Utilidade;

public class ConsultaDAO {
	public static HashSet<Consulta> getConsultaByPacienteId(int idPaciente) throws Exception {
		Connection conexao = Conexao.conectar();
		String sqlConsulta = "SELECT consultas.*, perfis.*, usuarios.* FROM consultas " 
				+ "JOIN perfis ON consultas.medico = perfis.id_perfil "
				+ "JOIN usuarios ON perfis.usuario = usuarios.id_usuario "
				+ "WHERE paciente = ?";
		PreparedStatement stmt = conexao.prepareStatement(sqlConsulta);
		stmt.setInt(1, idPaciente);
		ResultSet rs = stmt.executeQuery();
		HashSet<Consulta> consultasDoPaciente = new HashSet<Consulta>();
		while (rs.next()) {
			Usuario u = Utilidade.gerarUsuarioComDadosDoBD(rs);
			Perfil p = Utilidade.gerarPerfilComDadosDoBD(rs);
			//inserindo usuário
			p.setUsuario(u);
			Consulta c = Utilidade.gerarConsultaComDadosDoBD(rs);
			c.setMedicoConsulta(p);
			consultasDoPaciente.add(c);
		}
		conexao.close();
		return consultasDoPaciente;
	} 
}
