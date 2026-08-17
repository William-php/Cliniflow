package com.example.main.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class Conexao {
	private static final String URL = "jdbc:mysql://localhost:3306/cliniflow?useTimezone=true&serverTimezone=UTC";
	private static final String USUARIO = "root";
    private static final String SENHA = "12345";
    
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
    /*
    public static void main(String[] args) {
        try {
            System.out.println("Tentando conectar ao banco de dados...");
            Connection testeConexao = conectar();
            
            if (testeConexao != null) {
                System.out.println("SUCESSO! O Java conseguiu se conectar ao banco!");
                testeConexao.close();
            }
        } catch (Exception e) {
            System.out.println("Conexão falhou.");
            e.printStackTrace();
        }
    }*/
}