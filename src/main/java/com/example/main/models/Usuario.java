package com.example.main.models;

import java.time.LocalDateTime;

import com.example.main.enums.Sexo;
import com.example.main.enums.StatusUsuario;

public class Usuario {
	private int idUsuario;
	private String nomeUsuario;
	private String sobrenomeUsuario;
	private LocalDateTime dataNascimentoUsuario;
	private String cpfUsuario;
	private String emailUsuario;
	private String senhaUsuario;
	private StatusUsuario statusUsuario;
	private Sexo sexoUsuario;
	private boolean admUsuario;
	private String crmUsuario;
	
	public Usuario() {}
	
	public Usuario(
			String nomeUsuario,
			String sobrenomeUsuario,
			LocalDateTime dataNascimentoUsuario,
			String cpfUsuario,
			String emailUsuario,
			String senhaUsuario,
			StatusUsuario statusUsuario,
			Sexo sexoUsuario,
			boolean admUsuario,
			String crmUsuario
	) {
		this.nomeUsuario = nomeUsuario;
		this.sobrenomeUsuario = sobrenomeUsuario;
		this.dataNascimentoUsuario = dataNascimentoUsuario;
		this.cpfUsuario = cpfUsuario;
		this.emailUsuario = emailUsuario;
		this.senhaUsuario = senhaUsuario;
		this.statusUsuario = statusUsuario;
		this.sexoUsuario = sexoUsuario;
		this.admUsuario = admUsuario;
		this.crmUsuario = crmUsuario;
	}
	
	public Usuario(
			int	idUsuario,
			String nomeUsuario,
			String sobrenomeUsuario,
			LocalDateTime dataNascimentoUsuario,
			String cpfUsuario,
			String emailUsuario,
			String senhaUsuario,
			StatusUsuario statusUsuario,
			Sexo sexoUsuario,
			boolean admUsuario,
			String crmUsuario
	) {
		this.idUsuario = idUsuario;
		this.nomeUsuario = nomeUsuario;
		this.sobrenomeUsuario = sobrenomeUsuario;
		this.dataNascimentoUsuario = dataNascimentoUsuario;
		this.cpfUsuario = cpfUsuario;
		this.emailUsuario = emailUsuario;
		this.senhaUsuario = senhaUsuario;
		this.statusUsuario = statusUsuario;
		this.sexoUsuario = sexoUsuario;
		this.admUsuario = admUsuario;
		this.crmUsuario = crmUsuario;
	}

	// Getters e Setters
	public int getIdUsuario() {
		return idUsuario;
	}

	public void setIdUsuario(int idUsuario) {
		this.idUsuario = idUsuario;
	}

	public String getNomeUsuario() {
		return nomeUsuario;
	}

	public void setNomeUsuario(String nomeUsuario) {
		this.nomeUsuario = nomeUsuario;
	}

	public String getSobrenomeUsuario() {
		return sobrenomeUsuario;
	}

	public void setSobrenomeUsuario(String sobrenomeUsuario) {
		this.sobrenomeUsuario = sobrenomeUsuario;
	}

	public LocalDateTime getDataNascimentoUsuario() {
		return dataNascimentoUsuario;
	}

	public void setDataNascimentoUsuario(LocalDateTime dataNascimentoUsuario) {
		this.dataNascimentoUsuario = dataNascimentoUsuario;
	}

	public String getCpfUsuario() {
		return cpfUsuario;
	}

	public void setCpfUsuario(String cpfUsuario) {
		this.cpfUsuario = cpfUsuario;
	}

	public String getEmailUsuario() {
		return emailUsuario;
	}

	public void setEmailUsuario(String emailUsuario) {
		this.emailUsuario = emailUsuario;
	}

	public String getSenhaUsuario() {
		return senhaUsuario;
	}

	public void setSenhaUsuario(String senhaUsuario) {
		this.senhaUsuario = senhaUsuario;
	}

	public StatusUsuario getStatusUsuario() {
		return statusUsuario;
	}

	public void setStatusUsuario(StatusUsuario statusUsuario) {
		this.statusUsuario = statusUsuario;
	}

	public Sexo getSexoUsuario() {
		return sexoUsuario;
	}

	public void setSexoUsuario(Sexo sexoUsuario) {
		this.sexoUsuario = sexoUsuario;
	}

	public boolean isAdmUsuario() {
		return admUsuario;
	}

	public void setAdmUsuario(boolean admUsuario) {
		this.admUsuario = admUsuario;
	}

	public String getCrmUsuario() {
		return crmUsuario;
	}

	public void setCrmUsuario(String crmUsuario) {
		this.crmUsuario = crmUsuario;
	}
}