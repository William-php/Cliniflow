package com.example.main.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class Conexao {
	private static final String URL = "jdbc:mysql://localhost:3306/clinica?useTimezone=true&serverTimezone=UTC";
	private static final String USUARIO = "will";
    private static final String SENHA = "12345678";
    
    public static Connection conectar() throws SQLException, ClassNotFoundException {
    	Class.forName("com.mysql.cj.jdbc.Driver");
    	return DriverManager.getConnection(URL, USUARIO, SENHA);
    }
    
    public static PreparedStatement retornarStatement(String sql) throws SQLException, Exception {
    	Connection conexao = conectar();
    	PreparedStatement stmt = conexao.prepareStatement(sql);
    	conexao.close();
    	return stmt;
    }
}
