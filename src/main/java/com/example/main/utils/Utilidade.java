package com.example.main.utils;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import com.example.main.enums.Sexo;
import com.example.main.enums.StatusConsulta;
import com.example.main.enums.StatusListaEspera;
import com.example.main.enums.StatusUsuario;
import com.example.main.enums.TipoEspecialidade;
import com.example.main.enums.TipoPerfil;
import com.example.main.models.Consulta;
import com.example.main.models.Especialidade;
import com.example.main.models.ListaEspera;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;

public class Utilidade {
	public static LocalDateTime converterDatasParaLocalDateTime(String dataHoraBD) {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
		LocalDateTime dataConvertida = LocalDateTime.parse(dataHoraBD, formatter);		
		return dataConvertida; 
	}
	
	public static Usuario gerarUsuarioComDadosDoBD(ResultSet rs) throws SQLException {
		LocalDateTime dataHora = converterDatasParaLocalDateTime(rs.getString("data_nascimento_usuario"));
		StatusUsuario status = StatusUsuario.valueOf(rs.getString("status_usuario").toUpperCase());
		Sexo sexo = Sexo.valueOf(rs.getString("sexo_usuario").toUpperCase());
		Usuario u = new Usuario(
					rs.getInt("id_usuario"),
					rs.getString("nome_usuario"),
					rs.getString("sobrenome_usuario"),
					dataHora,
					rs.getString("cpf_usuario"),
					rs.getString("email_usuario"),
					rs.getString("senha_usuario"),
					status,
					sexo,
					rs.getBoolean("adm_usuario"),
					rs.getString("crm_usuario")
				);
		return u;
	}
	
	public static Perfil gerarPerfilComDadosDoBD(ResultSet rs) throws SQLException {
		TipoPerfil tipo = TipoPerfil.valueOf(rs.getString("tipo_perfil").toUpperCase());
		
		Perfil p = new Perfil(rs.getInt("id_perfil"), tipo, null, null);
		return p;
	}
	
	public static Consulta gerarConsultaComDadosDoBD(ResultSet rs) throws SQLException {
		StatusConsulta status = StatusConsulta.valueOf(rs.getString("status_consulta").toUpperCase());
		LocalDateTime dataHoraInicio = converterDatasParaLocalDateTime(rs.getString("data_hora_consulta_inicio"));
		LocalDateTime dataHoraFim = converterDatasParaLocalDateTime(rs.getString("data_hora_consulta_fim"));
		Consulta c = new Consulta(
					rs.getInt("id_consulta"),
					null, //perfil medico,
					null, //perfil paciente
					status,
					dataHoraInicio,
					dataHoraFim,
					null // lista_espera
				);
		return c;
				
	}
	
	public static Especialidade gerarEspecialidadesComDadosBD(ResultSet rs) throws SQLException {
		TipoEspecialidade tipo = TipoEspecialidade.valueOf(rs.getString("tipo_especialidade").toUpperCase());
		Especialidade e = new Especialidade(tipo, rs.getString("nome_especialidade"));
		return e;
	}
	
	public static ListaEspera gerarObjListaEsperaComDadosBD(ResultSet rs) throws SQLException {
		StatusListaEspera status = StatusListaEspera.valueOf(rs.getString("status_lista_espera").toUpperCase());
		ListaEspera LE = new ListaEspera(rs.getInt("posicao_lista_espera"), status);
		return LE;
	}
}
