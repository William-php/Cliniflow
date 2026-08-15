package com.example.main.models;

import java.util.HashSet;

import com.example.main.enums.TipoEspecialidade;

public class Especialidade {
	private int idEspecialidade;
	private TipoEspecialidade tipoEspecialidade;
	private String nomeEspecialidade;
	private HashSet<Perfil> listaMedico;
	
	public Especialidade() {}
	
	public Especialidade(TipoEspecialidade tipoEspecialidade, String nomeEspecialidade) {
		this.tipoEspecialidade = tipoEspecialidade;
		this.nomeEspecialidade = nomeEspecialidade;
	}
	
	public Especialidade(int idEspecialidade, TipoEspecialidade tipoEspecialidade, String nomeEspecialidade) {
		this.idEspecialidade = idEspecialidade;
		this.tipoEspecialidade = tipoEspecialidade;
		this.nomeEspecialidade = nomeEspecialidade;
	}

	
	
	public HashSet<Perfil> getListaMedico() {
		return listaMedico;
	}

	public void setListaMedico(HashSet<Perfil> listaMedico) {
		this.listaMedico = listaMedico;
	}

	public int getIdEspecialidade() {
		return idEspecialidade;
	}

	public void setIdEspecialidade(int idEspecialidade) {
		this.idEspecialidade = idEspecialidade;
	}

	public TipoEspecialidade getTipoEspecialidade() {
		return tipoEspecialidade;
	}

	public void setTipoEspecialidade(TipoEspecialidade tipoEspecialidade) {
		this.tipoEspecialidade = tipoEspecialidade;
	}

	public String getNomeEspecialidade() {
		return nomeEspecialidade;
	}

	public void setNomeEspecialidade(String nomeEspecialidade) {
		this.nomeEspecialidade = nomeEspecialidade;
	}
	
	
}
