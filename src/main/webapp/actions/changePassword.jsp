<%@page import="org.json.JSONWriter"%>
<%@page import="geotech.Permissions"%>
<%@page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@page import="geotech.Database"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils" %>
<%
JSONWriter output = new JSONWriter(out);

if (request.getParameter("newPassword") != null) {
	String newPassword = request.getParameter("newPassword");
	String userId, filter;
	
	String target = request.getParameter("target");
	
	if (target != null && target.length() > 0) {
		if (!Permissions.canWrite(session, "config_usuarios_senha", response, out))
			return;
		
		userId = target;
		filter = "";
	}
	else {
		String current = request.getParameter("current") != null ? request.getParameter("current") : "";
		userId = (String) session.getAttribute("userId");
		filter = " AND password = MD5('"+ StringEscapeUtils.escapeSql(current) + "')";
	}

	if (newPassword.length() > 7 ) {
		
		Database db =  new Database();
		ResultSet result =  null;
		
		String sql = "UPDATE gt_users SET password = MD5('" + StringEscapeUtils.escapeSql(newPassword) + "') WHERE id = " + userId + filter;
		if (db.update(sql) == 1) {
			output.object();
			output.key("success").value(true);
			output.key("message").value("Senha alterada com sucesso.");
			output.endObject();
		}
		else {
			output.object();
			output.key("success").value(false);
			output.key("message").value("Não foi possível alterar a senha.");
			output.endObject();
		}
		
		db.close();
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível alterar a senha. Por favor, informe uma nova senha com pelo menos 8 caracteres.");
		output.endObject();
	}
}
else {
	output.object();
	output.key("success").value(false);
	output.key("message").value("Parâmetros incorretos.");
	output.endObject();
}
%>