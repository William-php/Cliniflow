	package com.example.main.models;

import java.time.LocalDateTime;
import java.util.HashSet;

import com.example.main.enums.StatusConsulta;

public class Consulta {
	private int idConsulta;
	private Perfil medicoConsulta;
	private Perfil pacienteConsulta;
	private StatusConsulta statusConsulta;
	private LocalDateTime dataHoraInicioConsulta;
	private LocalDateTime dataHoraFimConsulta;
	private HashSet<ListaEspera> listaEspera;
	
	public Consulta() {}
	
	public Consulta(
			Perfil medicoConsulta,
			Perfil pacienteConsulta,
			StatusConsulta statusConsulta,
			LocalDateTime dataHoraInicioConsulta,
			LocalDateTime dataHoraFimConsulta
	) {
		this.medicoConsulta = medicoConsulta;
		this.pacienteConsulta = pacienteConsulta;
		this.statusConsulta = statusConsulta;
		this.dataHoraInicioConsulta = dataHoraInicioConsulta;
		this.dataHoraFimConsulta = dataHoraFimConsulta;
	}
	
	public Consulta(
			Perfil medicoConsulta,
			Perfil pacienteConsulta,
			StatusConsulta statusConsulta,
			LocalDateTime dataHoraInicioConsulta,
			LocalDateTime dataHoraFimConsulta,
			HashSet<ListaEspera> listaEspera
	) {
		this.medicoConsulta = medicoConsulta;
		this.pacienteConsulta = pacienteConsulta;
		this.statusConsulta = statusConsulta;
		this.dataHoraInicioConsulta = dataHoraInicioConsulta;
		this.dataHoraFimConsulta = dataHoraFimConsulta;
		this.listaEspera = listaEspera;
	}
	
	public Consulta(
			int idConsulta,
			Perfil medicoConsulta,
			Perfil pacienteConsulta,
			StatusConsulta statusConsulta,
			LocalDateTime dataHoraInicioConsulta,
			LocalDateTime dataHoraFimConsulta,
			HashSet<ListaEspera> listaEspera
	) {
		this.idConsulta = idConsulta;
		this.medicoConsulta = medicoConsulta;
		this.pacienteConsulta = pacienteConsulta;
		this.statusConsulta = statusConsulta;
		this.dataHoraInicioConsulta = dataHoraInicioConsulta;
		this.dataHoraFimConsulta = dataHoraFimConsulta;
		this.listaEspera = listaEspera;
	}
	
	public HashSet<ListaEspera> getListaEspera() {
		return listaEspera;
	}

	public void setListaEspera(HashSet<ListaEspera> listaEspera) {
		this.listaEspera = listaEspera;
	}

	public int getIdConsulta() {
		return idConsulta;
	}

	public void setIdConsulta(int idConsulta) {
		this.idConsulta = idConsulta;
	}

	public Perfil getMedicoConsulta() {
		return medicoConsulta;
	}

	public void setMedicoConsulta(Perfil medicoConsulta) {
		this.medicoConsulta = medicoConsulta;
	}

	public Perfil getPacienteConsulta() {
		return pacienteConsulta;
	}

	public void setPacienteConsulta(Perfil pacienteConsulta) {
		this.pacienteConsulta = pacienteConsulta;
	}

	public StatusConsulta getStatusConsulta() {
		return statusConsulta;
	}

	public void setStatusConsulta(StatusConsulta statusConsulta) {
		this.statusConsulta = statusConsulta;
	}

	public LocalDateTime getDataHoraInicioConsulta() {
		return dataHoraInicioConsulta;
	}

	public void setDataHoraInicioConsulta(LocalDateTime dataHoraInicioConsulta) {
		this.dataHoraInicioConsulta = dataHoraInicioConsulta;
	}

	public LocalDateTime getDataHoraFimConsulta() {
		return dataHoraFimConsulta;
	}

	public void setDataHoraFimConsulta(LocalDateTime dataHoraFimConsulta) {
		this.dataHoraFimConsulta = dataHoraFimConsulta;
	}	
}
