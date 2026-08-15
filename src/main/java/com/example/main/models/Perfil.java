package com.example.main.models;

import java.util.HashSet;

import com.example.main.enums.TipoPerfil;

public class Perfil {
	private int idPerfil;
	private TipoPerfil tipoPerfil;
	private Usuario usuario;
	private HashSet<Especialidade> especialidadesMedico;
	
	public Perfil() {}
	
	public Perfil(TipoPerfil tipoPerfil) {
		this.tipoPerfil = tipoPerfil;		
	}
	
	public Perfil(TipoPerfil tipoPerfil, Usuario usuario) {
		this.tipoPerfil = tipoPerfil;
		this.usuario = usuario;
	}
	public Perfil(TipoPerfil tipoPerfil, Usuario usuario, HashSet<Especialidade> especialidadesMedico) {
		this.tipoPerfil = tipoPerfil;
		this.usuario = usuario;
		this.especialidadesMedico = especialidadesMedico;
	}
	
	public Perfil(int idPerfil, TipoPerfil tipoPerfil, Usuario usuario, HashSet<Especialidade> especialidadesMedico) {
		this.idPerfil = idPerfil;
		this.tipoPerfil = tipoPerfil;
		this.usuario = usuario;
		this.especialidadesMedico = especialidadesMedico;
	}

	public HashSet<Especialidade> getEspecialidadesMedico() {
		return especialidadesMedico;
	}

	public void setEspecialidadesMedico(HashSet<Especialidade> especialidadesMedico) {
		this.especialidadesMedico = especialidadesMedico;
	}

	public int getIdPerfil() {
		return idPerfil;
	}

	public void setIdPerfil(int idPerfil) {
		this.idPerfil = idPerfil;
	}

	public TipoPerfil getTipoPerfil() {
		return tipoPerfil;
	}

	public void setTipoPerfil(TipoPerfil tipoPerfil) {
		this.tipoPerfil = tipoPerfil;
	}

	public Usuario getUsuario() {
		return usuario;
	}

	public void setUsuario(Usuario usuario) {
		this.usuario = usuario;
	}
	
	
}
