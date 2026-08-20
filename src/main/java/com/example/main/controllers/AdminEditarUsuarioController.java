package com.example.main.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashSet;
import java.util.List;

import com.example.main.dao.EspecialidadeDAO;
import com.example.main.dao.UsuarioDAO;
import com.example.main.models.Especialidade;
import com.example.main.models.Perfil;
import com.example.main.models.Usuario;
import com.example.main.utils.Conexao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "adminEditarUsuario", urlPatterns = {"/admin-editar-usuario"})
public class AdminEditarUsuarioController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Perfil adminLogado = (Perfil) session.getAttribute("usuarioLogado");
        
        if (adminLogado != null && adminLogado.getUsuario() != null && adminLogado.getUsuario().isAdmUsuario()) {
            try {
                int idUsuario = Integer.parseInt(request.getParameter("id"));
                Usuario usuarioEdit = UsuarioDAO.getUsuarioById(idUsuario);
                
                if (usuarioEdit != null) {
                    request.setAttribute("usuarioEdit", usuarioEdit);
                    
                    int idPerfil = 0;
                    String tipoPerfil = "";
                    
                    try (Connection conn = Conexao.conectar();
                         PreparedStatement stmt = conn.prepareStatement("SELECT id_perfil, tipo_perfil FROM perfis WHERE usuario = ?")) {
                        stmt.setInt(1, idUsuario);
                        ResultSet rs = stmt.executeQuery();
                        if (rs.next()) {
                            idPerfil = rs.getInt("id_perfil");
                            tipoPerfil = rs.getString("tipo_perfil");
                        }
                    }
                    
                    request.setAttribute("idPerfilEdit", idPerfil);
                    request.setAttribute("tipoPerfilEdit", tipoPerfil);
                    
                    // carrega todas especialidades cadastradas
                    HashSet<Especialidade> todasEsp = EspecialidadeDAO.getEspecialidades();
                    request.setAttribute("listaEspecialidades", todasEsp);
                    
                    // carrega especialidades vinculadas a esse perfil
                    if (idPerfil > 0) {
                        List<Integer> vinculadas = EspecialidadeDAO.getIdsEspecialidadesDoMedico(idPerfil);
                        request.setAttribute("especialidadesVinculadas", vinculadas);
                    }
                    
                    request.getRequestDispatcher("admin-editar-usuario.jsp").forward(request, response);
                } else {
                    response.sendRedirect("admin-usuarios?erro=nao_encontrado");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("admin-usuarios");
            }
        } else {
            response.sendRedirect("index.jsp");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int idUsuario = Integer.parseInt(request.getParameter("id_usuario"));
            Usuario usuarioAtualizado = UsuarioDAO.getUsuarioById(idUsuario);
            
            if (usuarioAtualizado != null) {
                usuarioAtualizado.setNomeUsuario(request.getParameter("nome_usuario"));
                usuarioAtualizado.setSobrenomeUsuario(request.getParameter("sobrenome_usuario"));
                usuarioAtualizado.setEmailUsuario(request.getParameter("email_usuario"));
                usuarioAtualizado.setCpfUsuario(request.getParameter("cpf_usuario"));
                
                String crmParam = request.getParameter("crm_usuario");
                if (crmParam != null && !crmParam.trim().isEmpty()) {
                    usuarioAtualizado.setCrmUsuario(crmParam);
                }
                
                String dataString = request.getParameter("data_nascimento_usuario");
                if (dataString != null && !dataString.isEmpty()) {
                    java.time.LocalDateTime dataConvertida = java.time.LocalDate.parse(dataString).atStartOfDay();
                    usuarioAtualizado.setDataNascimentoUsuario(dataConvertida);
                }
                
                String sexoParam = request.getParameter("sexo_usuario");
                if (sexoParam != null) {
                    usuarioAtualizado.setSexoUsuario(com.example.main.enums.Sexo.valueOf(sexoParam.toUpperCase()));
                }
                
                String statusParam = request.getParameter("status_usuario");
                if (statusParam != null && statusParam.equals("ATIVO")) {
                    usuarioAtualizado.setStatusUsuario(com.example.main.enums.StatusUsuario.ATIVO);
                } else {
                    usuarioAtualizado.setStatusUsuario(com.example.main.enums.StatusUsuario.DESATIVADO);
                }
                
                UsuarioDAO.putUsuarioById(usuarioAtualizado);
                
                // atualiza especialidades vinculadas ao perfil medico
                String idPerfilParam = request.getParameter("id_perfil");
                if (idPerfilParam != null && !idPerfilParam.isEmpty() && !"0".equals(idPerfilParam)) {
                    int idPerfil = Integer.parseInt(idPerfilParam);
                    String[] especialidadesMarcadas = request.getParameterValues("especialidades_medico");
                    EspecialidadeDAO.atualizarEspecialidadesDoMedico(idPerfil, especialidadesMarcadas);
                }
                
                response.sendRedirect("admin-usuarios?sucesso=editado");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-usuarios?erro=falha");
        }
    }
}