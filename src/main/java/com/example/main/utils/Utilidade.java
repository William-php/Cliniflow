package com.example.main.utils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Utilidade {
	public static LocalDateTime converterDatasParaLocalDateTime(String dataHoraBD) {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
		LocalDateTime dataConvertida = LocalDateTime.parse(dataHoraBD, formatter);		
		return dataConvertida; 
	}
}
