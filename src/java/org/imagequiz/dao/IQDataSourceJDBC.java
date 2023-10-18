/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.dao;

import java.io.InputStream;
import static java.lang.System.in;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import org.imagequiz.model.IQCaseDAO;

/**
 *
 * @author apavel
 */
public class IQDataSourceJDBC {

    public Connection getConnection() throws Exception {
        InitialContext initialContext = new InitialContext();
        Context context = (Context) initialContext.lookup("java:comp/env");
        //The JDBC Data source that we just created
        DataSource ds = (DataSource) context.lookup("imagequiz");
        Connection connection = ds.getConnection();
 
        if (connection == null)
        {
            throw new SQLException("Error establishing connection!");
        }
        return connection;
    }
    
    //returns true if database created
    /*
    public boolean ensureDatabaseCreated() throws Exception {
        Connection conn = this.getConnection();
        Statement st = null;
	
        InputStream in = ClassLoader.class.getResourceAsStream("/org/imagequiz/dao/init.sql");
        Scanner s = new Scanner(in);
	s.useDelimiter("(;(\r)?\n)|(--\n)");
	try
	{
		st = conn.createStatement();
		while (s.hasNext())
		{
			String line = s.next();*/
			//if (line.startsWith("/*!") && line.endsWith("*/")) 
			/*{
				int i = line.indexOf(' ');*/
				//line = line.substring(i + 1, line.length() - " */".length());
			/*}

			if (line.trim().length() > 0)
			{
				st.execute(line);
			}
                }
        } catch (SQLException e) {
            conn.close();
        } finally {
            conn.close();
        }
    }*/
    
    public ResultSet getResultSet(String query) throws Exception {
        Connection con = this.getConnection();
        PreparedStatement statement;
        ResultSet rs = null;
        try {
            statement = con.prepareStatement(query);
            rs = statement.executeQuery();
        } catch (SQLException e) {
        	e.printStackTrace();
            con.close();
        } finally {
            con.close();
        }
        return rs;
    }
    
    private IQCaseDAO createIQCase(ResultSet rs) throws SQLException {
        IQCaseDAO iqCase = new IQCaseDAO();
        iqCase.setCasetext(rs.getString("casetext"));
        iqCase.setFilename(rs.getString("filename"));
        iqCase.setId(rs.getLong("id"));
        iqCase.setQuestionxml(rs.getString("questionxml"));
        return iqCase;
    }
    
    
    
    @SuppressWarnings("empty-statement")
    public IQCaseDAO getIQCase(String id) throws Exception {
        IQCaseDAO iqCase = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            stmt = conn.prepareStatement("select * from iqcase where id='" + id + "'");
            rs = stmt.executeQuery();
            while (rs.next()) {
                iqCase = createIQCase(rs);
            }
        } catch (Exception sqe) {
            throw sqe;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {};
            try { if (stmt != null) stmt.close(); } catch (Exception e) {};
            try { if (conn != null) conn.close(); } catch (Exception e) {};
        }
        
        return iqCase;
    }
        
    @SuppressWarnings("empty-statement")
    public IQCaseDAO getLastIQCase() throws Exception {
        IQCaseDAO iqCase = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            stmt = conn.prepareStatement("select * from iqcase ORDER by id");
            rs = stmt.executeQuery();
            if (rs.last()) {
                iqCase = createIQCase(rs);
            }

        } catch (Exception sqe) {
            throw sqe;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {};
            try { if (stmt != null) stmt.close(); } catch (Exception e) {};
            try { if (conn != null) conn.close(); } catch (Exception e) {};
        }
        
        return iqCase;
    }
    
    @SuppressWarnings("empty-statement")
    public Long addIQCase(IQCaseDAO iqCase) throws Exception {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Long returnId = null;
        try {
            conn = getConnection();
            stmt = conn.prepareStatement("INSERT INTO iqcase (casetext, questionxml, filename) VALUES (?, ?, ?)", Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, iqCase.getCasetext());
            stmt.setString(2, iqCase.getQuestionxml());
            stmt.setString(3, iqCase.getFilename());
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) { throw new SQLException("Failed creating row"); }
            rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                returnId = rs.getLong(1);
            }
        } catch (Exception sqe) {
            throw sqe;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {};
            try { if (stmt != null) stmt.close(); } catch (Exception e) {};
            try { if (conn != null) conn.close(); } catch (Exception e) {};
        }
        return returnId;
    }
    
}
