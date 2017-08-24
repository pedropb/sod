<%@page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@page import="geotech.Database"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils" %>

<%
	String action = request.getParameter("action");
	action = action == null ? "" : action;
	
	if(action.equals("login")){
		Database db =  Database.createDatabase();
		ResultSet result =  null;
		String sql = "";
		
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		
		sql = 	"SELECT\n" +
				"	id,\n" +
				"	active \n" +
			  	"FROM\n" +
				"	gt_users\n" +
			  	"WHERE\n" +
				"	LOWER(login) = LOWER('" + StringEscapeUtils.escapeSql(username) + "')\n" +
			  	"	AND password = MD5('" + password + "')\n" +
			  	"	AND initialized = TRUE";
		
		result = db.query(sql);
		if(result.next()){
			String id = result.getString("id");
			boolean active = result.getBoolean("active");
			
			if (active){
				session.setAttribute("userId", id);
				
				out.println("{success: true}");
			}
			else
				out.println("{success: false, msg: 'Usuário desativado.'}");
		}
		else{
			out.println("{success: false, msg: 'Login / Senha incorretos(s).'}");
		}
		
		db.close();
	}
	else if(action.equals("logout")){
		session.removeAttribute("userId");
		
		String message = request.getParameter("message");
		if (message != null)
			session.setAttribute("message", request.getParameter("message"));
		
		response.sendRedirect("../index.jsp");
	}
%>