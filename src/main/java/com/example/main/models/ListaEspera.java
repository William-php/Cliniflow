package com.example.main.models;

import java.util.HashSet;

import com.example.main.enums.StatusListaEspera;

public class ListaEspera {
	private Perfil medicoListaEspera;
	private Perfil pacientesListaEspera;
	private int posicaoListaEspera;
	private StatusListaEspera statusListaEspera;
	
	public ListaEspera() {}
	
	public ListaEspera(
			Perfil medicoListaEspera,
			Perfil pacientesListaEspera,
			int posicaoListaEspera,
			StatusListaEspera statusListaEspera
	) {
		this.medicoListaEspera = medicoListaEspera;
		this.pacientesListaEspera = pacientesListaEspera;
		this.posicaoListaEspera = posicaoListaEspera;
		this.statusListaEspera = statusListaEspera;
	}
	
	public Perfil getMedicoListaEspera() {
		return medicoListaEspera;
	}

	public void setMedicoListaEspera(Perfil medicoListaEspera) {
		this.medicoListaEspera = medicoListaEspera;
	}

	public ListaEspera(			
			Perfil pacientesListaEspera,
			int posicaoListaEspera,
			StatusListaEspera statusListaEspera
	) {
		
		this.pacientesListaEspera = pacientesListaEspera;
		this.posicaoListaEspera = posicaoListaEspera;
		this.statusListaEspera = statusListaEspera;
	}
	
	public ListaEspera(						
			int posicaoListaEspera,
			StatusListaEspera statusListaEspera
	) {
				
		this.posicaoListaEspera = posicaoListaEspera;
		this.statusListaEspera = statusListaEspera;
	}

	public Perfil getPacientesListaEspera() {
		return pacientesListaEspera;
	}

	public void setPacientesListaEspera(Perfil pacientesListaEspera) {
		this.pacientesListaEspera = pacientesListaEspera;
	}

	public int getPosicaoListaEspera() {
		return posicaoListaEspera;
	}

	public void setPosicaoListaEspera(int posicaoListaEspera) {
		this.posicaoListaEspera = posicaoListaEspera;
	}

	public StatusListaEspera getStatusListaEspera() {
		return statusListaEspera;
	}

	public void setStatusListaEspera(StatusListaEspera statusListaEspera) {
		this.statusListaEspera = statusListaEspera;
	}	
}
