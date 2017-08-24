/*
 * Copyright 2012 by Pedro Baracho
 * pedropbaracho@gmail.com
 */

package geotech;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import org.apache.commons.lang.StringEscapeUtils;

/* 
 * Implements PostgreSQL database manipulation methods.
 */
public class Database
{
	private Connection connection;
	private String url;

	public static Database createDatabase() {
		try {
			Context ctx = new InitialContext();
			Context env = (Context) ctx.lookup("java:comp/env");
			final String host = (String) env.lookup("host");
			final String port = (String) env.lookup("port");
			final String user = (String) env.lookup("user");
			final String pass = (String) env.lookup("pass");
			final String database = (String) env.lookup("database");

			return new Database(database, user, pass, host, port);
		}
		catch (NamingException ex) {
			System.err.println("Could not load environment properties from web.xml.");
			ex.printStackTrace();
			return null;
		}
	}
			
	/*
	 * Constructs the database object.
	 * @param db The database name
	 * @param user The user name
	 * @param password The password
	 * @param host The database host address
	 * @param port The database connection port
	 */
	public Database(String db, String user, String password, String host, String port)
	{
		this.url = "jdbc:postgresql://" + host + ":" + port + "/" + db + "?useUnicode=true&characterEncoding=UTF-8";
		
		try {
			Class.forName("org.postgresql.Driver");
			this.connection = DriverManager.getConnection(url, user, password);
		} catch (ClassNotFoundException ex)
		{
			System.err.println("Connection driver not found.");
			ex.printStackTrace();
			this.connection = null;
			return;
		} catch (SQLException ex)
		{
			System.err.println("Could not connect to the database.");
			ex.printStackTrace();
			this.connection = null;
			return;
		}
	}
	
	/*
	 * Validates the query to prevent SQL injections.
	 * @param query The query to be validated
	 * @return True if the query is valid; False otherwise.
	 */
	private static boolean validateQuery (String query){
		query = query.trim( );
		
		char [] vector = query.toCharArray();
		
		boolean flag = false;		
		for(int i = 0; i < vector.length; i++){
			if(vector[i] == '\''){
				flag = !flag;
			}
			
			if(!flag && vector[i] == ';' && i != vector.length - 1){
				return false;
			}			
		}
		
		return true;
	}
	
	/*
	 * Executes the given SQL statement, which returns a single ResultSet object.
	 * @param query An SQL statement to be sent to the database, typically a static SQL SELECT statement
	 * @return A ResultSet object that contains the data produced by the given query.
	 */
	public ResultSet query(String query)
	{
		if (!validateQuery(query)) {
			System.err.println("Invalid query.\n" + query);
			return null;
		}
		
		try {
			PreparedStatement stm = this.connection.prepareStatement(query);
			ResultSet resultado = stm.executeQuery();
			return resultado;
		} catch(Exception ex)
		{
			System.err.println("Execution failed. Query:\n" + query);
			ex.printStackTrace();
			return null;
		}
	}

	/*
	 * Executes the given SQL statement, which may be an INSERT, UPDATE, or DELETE statement or an SQL statement that returns nothing, such as an SQL DDL statement.
	 * @param query An SQL INSERT, UPDATE or DELETE statement or an SQL statement that returns nothing
	 * @return Either the row count for INSERT, UPDATE or DELETE statements, or 0 for SQL statements that return nothing
	 */
	public int update(String query)
	{
		return update(query, true);
	}

	/*
	 * Executes the given SQL statement, which may be an INSERT, UPDATE, or DELETE statement or an SQL statement that returns nothing, such as an SQL DDL statement.
	 * @param query An SQL INSERT, UPDATE or DELETE statement or an SQL statement that returns nothing
	 * @return Either the row count for INSERT, UPDATE or DELETE statements, or 0 for SQL statements that return nothing
	 */
	public int update(String query, boolean validate)
	{
		if (validate) {
			if (!validateQuery(query)) {
				System.err.println("Invalid query.\n" + query);
				return 0;
			}
		}
		
		try {
			PreparedStatement stm = this.connection.prepareStatement(query);
			int result = stm.executeUpdate();
			return result;
		} catch(Exception ex)
		{
			System.err.println(ex.getMessage());
			ex.printStackTrace();	
			return 0;
		}
	}

	public boolean execute(String query)
	{
		if (!validateQuery(query)) {
			System.err.println("Invalid query.\n" + query);
			return false;
		}
		
		try {
			PreparedStatement stm = this.connection.prepareStatement(query);
			return stm.execute();
		} catch(Exception ex)
		{
			System.err.println("Execution failed. Query:\n" + query);
			ex.printStackTrace();
			return false;
		}
	}

	/*
	 * Sets the database connection's auto-commit mode to the given state.
	 * @param value True to enable auto-commit mode; False to disable it
	 */
	public void setAutoCommit(boolean value){
		try {  
			this.connection.setAutoCommit(value);   
		} catch (Exception e) {
		     System.err.println(e);  
		}  
	}
	
	/*
	 * Makes all changes made since the previous commit/rollback permanent and releases any database locks currently held by this database connection object. This method should be used only when auto-commit mode is set to false.
	 */
	public void commit(){
		try {  
			this.connection.commit();
		} catch (Exception e) {
		     System.err.println(e);  
		}  
	}
	
	public void save() {
		try {  
			this.connection.setSavepoint();
		} catch (Exception e) {
		     System.err.println(e);  
		}  
	}
	
	/*
	 * Undoes all changes made in the current transaction and releases any database locks currently held by this Connection object. This method should be used only when auto-commit mode is set to false.
	 */
	public void rollback(){
		try {  
			this.connection.rollback();   
		} catch (Exception e) {
		     System.err.println(e);  
		}  
	}
	
	/*
	 * Generates a SQL string representing the instantiation of a composite type.
	 * @param compType The name of the composite type
	 * @param parameters An array of parameters that forms the composite type
	 * @return The generated SQL string.
	 */
	public static String getSqlCompType (String compType, ArrayList <String> parameters) {
		return getSqlCompType(compType, parameters);
	}

	/*
	 * Generates a SQL string representing the instantiation of a composite type.
	 * @param compType The name of the composite type
	 * @param parameters An array of parameters that forms the composite type
	 * @return The generated SQL string.
	 */
	public static String getSqlCompType (String compType, String [] parameters) {
		if (parameters.length > 0) {
			boolean isString = true;
			
			String parameter = parameters[0].trim();
			if (parameter.startsWith("CAST((") || parameter.startsWith("ARRAY["))
				isString = false;
			
			return getSqlCompType(compType, parameters, isString);
		}
		
		return "";
	}

	/*
	 * Generates a SQL string representing the instantiation of a composite type.
	 * @param compType The name of the composite type
	 * @param parameters An array of parameters that forms the composite type
	 * @param isString True to enclose with parameters with ' and escape SQL String
	 * @return The generated SQL string.
	 */
	public static String getSqlCompType (String compType, String [] parameters, boolean isString) {
		String result = "CAST((";
		
		boolean first = true;
		for (String parameter : parameters) {
			if (!first) 
				if (isString)
					result += ", '" + StringEscapeUtils.escapeSql(parameter) + "'";
				else
					result += ", " + parameter;
			else {
				if (isString)
					result += "'" + StringEscapeUtils.escapeSql(parameter) + "'";
				else
					result += parameter;
				first = false;
			}
		}
		
		result += ") AS " + compType + ")";
		return result;
	}
	
	/*
	 * Generates a SQL string representing the instantiation of an array.
	 * @param parameters The parameters array
	 * @return The generated SQL string.
	 */
	public static String getSqlArray (ArrayList <String> parameters) {
		String [] p = new String [parameters.size()];
		parameters.toArray(p);
		
		return getSqlArray(p);
	}
	
	/*
	 * Generates a SQL string representing the instantiation of an array.
	 * @param parameters The parameters array
	 * @return The generated SQL string.
	 */
	public static String getSqlArray (String [] parameters) {
		if (parameters.length == 0)
			return "NULL";
		
		String result = "ARRAY[";
		
		boolean first = true;
		for (String parameter : parameters) {
			if (!first) 
				result += ", " + parameter;
			else {
				result += parameter;
				first = false;
			}
		}
		result += "]";
		return result;
	}
	
	/*
	 * Releases the database connection object and JDBC resources immediately instead of waiting for them to be automatically released.
	 */
	public void close()
	{
		try {
			this.connection.close();
		} catch(Exception ex)
		{
			System.err.println("Could not close database connection.");
			ex.printStackTrace();
		}
	}
	
	/*
	 * Closes the connection and destroy the database object.
	 * @see java.lang.Object#finalize()
	 */
	public void finalize()
	{
		this.close();
		try {
			super.finalize();
		} catch (Throwable e) {
			e.printStackTrace();
		}
	}
	
	public void cleanTable(String tableName) {
		String sql = "ALTER TABLE " + tableName + " DISABLE TRIGGER ALL";
		this.execute(sql);
		sql = "TRUNCATE TABLE " + tableName + " CASCADE";
		this.execute(sql);
		sql = "ALTER TABLE " + tableName + " ENABLE TRIGGER ALL";
		this.execute(sql);
	}
}
