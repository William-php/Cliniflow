package com.example.main.models;

import java.time.LocalDate;
import java.time.LocalTime;

public class AgendaMedico {
    private int idAgenda;
    private Perfil medico;
    private Especialidade especialidade;
    private LocalDate dataAgenda;
    private LocalTime horaInicio;
    private LocalTime horaFim;
    private String statusAgenda; // 'Disponivel' ou 'Bloqueada'

    public int getIdAgenda() { return idAgenda; }
    public void setIdAgenda(int idAgenda) { this.idAgenda = idAgenda; }

    public Perfil getMedico() { return medico; }
    public void setMedico(Perfil medico) { this.medico = medico; }

    public Especialidade getEspecialidade() { return especialidade; }
    public void setEspecialidade(Especialidade especialidade) { this.especialidade = especialidade; }

    public LocalDate getDataAgenda() { return dataAgenda; }
    public void setDataAgenda(LocalDate dataAgenda) { this.dataAgenda = dataAgenda; }

    public LocalTime getHoraInicio() { return horaInicio; }
    public void setHoraInicio(LocalTime horaInicio) { this.horaInicio = horaInicio; }

    public LocalTime getHoraFim() { return horaFim; }
    public void setHoraFim(LocalTime horaFim) { this.horaFim = horaFim; }

    public String getStatusAgenda() { return statusAgenda; }
    public void setStatusAgenda(String statusAgenda) { this.statusAgenda = statusAgenda; }
}