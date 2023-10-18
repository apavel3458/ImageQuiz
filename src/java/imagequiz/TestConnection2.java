/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package imagequiz;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author apavel
 */
public class TestConnection2 {

  public static void main(String[] args) {
  try {
  /* Create string of connection url within 
            specified format with machine name, 
  port number and database name. Here machine
            name id localhost and database 
            name is usermaster. */
  String connectionURL = 
            "jdbc:mysql://localhost:3306/imagequiz";
  // declare a connection by using Connection interface 
  Connection connection = null;
        // declare object of Statement interface that uses for executing sql statements.
  Statement statement = null;
            // declare a resultset that uses as a table for output data from the table.
  ResultSet rs = null;
  int updateQuery = 0;
  // Load JBBC driver "com.mysql.jdbc.Driver".
  Class.forName("com.mysql.jdbc.Driver").newInstance();
  /* Create a connection by using getConnection()
            method that takes parameters of string type 
            connection url, user name and password to 
            connect to database. */
  connection = DriverManager.getConnection(connectionURL, "root", "liyi");
  
        /* createStatement() is used for create 
            statement object that is used for sending sql 
            statements to the specified database. */
  statement = connection.createStatement();
  // sql query of string type to create a data base.
  String QueryString = "select * from iqcase";
  
  rs = statement.executeQuery(QueryString);
  while (rs.next()) {
  System.out.println(rs.getString(2));
  }
  // close all the connections.
  rs.close();
  statement.close();
  connection.close();
  } 
  catch (Exception ex) {
  System.out.println("Unable to connect to batabase.");
  }
  }
}
