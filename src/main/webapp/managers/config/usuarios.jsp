<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSetMetaData"%>
<%@page import="geotech.Permissions"%>
<%@page import="org.json.JSONWriter"%>
<%@page import="geotech.Database"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%
String action = request.getParameter("action");

JSONWriter output = new JSONWriter(out);

if (!Permissions.canWrite(session, "config_usuarios", response, out))
	return;

if (action == null) {
	response.setStatus(400);
	
	output.object();
	output.key("success").value(false);
	output.key("message").value("Action é obrigatório");
	output.endObject();
	
	return;
}

Database db = Database.createDatabase();
	
String sql;

if (action.equals("add")) {
	sql = "INSERT INTO gt_users(active) VALUES (TRUE)";
	if (db.update(sql) > 0) {
		sql = 	"SELECT\n" + 
				"	u.id,\n" +
				"	u.login,\n" +
				"	u.active,\n" +
				"	CASE WHEN ug.group_id IS NULL THEN -1 ELSE ug.group_id END AS grupo\n" +
				"FROM\n" + 
				"	gt_users u\n" +
				"	LEFT JOIN (SELECT user_id, MAX(group_id) group_id FROM gt_users_groups GROUP BY user_id) ug ON u.id = ug.user_id\n" +
				"WHERE\n" +
				"	u.id = CURRVAL('gt_users_id_seq')";
		
		ResultSet result = db.query(sql);
		
		ResultSetMetaData metadata = result.getMetaData();
		int columnCount = metadata.getColumnCount();
		String[] columns = new String[columnCount];
		for (int i = 0; i < columnCount; i++) {
			columns[i] = metadata.getColumnName(i + 1);
		}
		
		if (result.next()) {
			output.object();
			output.key("success").value(true);
			output.key("record").object();
			
			for (int i = 0; i < columnCount; i++) {
				output.key(columns[i]).value(result.getObject(columns[i]));
			}
			
			output.endObject();
			output.endObject();
		}
		else {
			output.object();
			output.key("success").value(false);
			output.key("message").value("Não foi possível acessar o registro no banco de dados. Se o problema persistir, entre em contato com o administrador do sistema.");
			output.endObject();
		}
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível criar o registro no banco de dados. Se o problema persistir, entre em contato com o administrador do sistema.");
		output.endObject();
	}
}
else if (action.equals("edit") && request.getParameter("id") != null) {
	
   	String userId = request.getParameter("id");
	String groupId = request.getParameter("grupo");
	
	String login = request.getParameter("login");
	String password = request.getParameter("password");
	String active = request.getParameter("ativo");
	
	if (password != null && password.length() > 0) {
		password = "password = MD5('" + StringEscapeUtils.escapeSql(password) + "'),\n";
	}
	else {
		password = "";
	}
	
	if (active != null && active.equals("on")) {
		active = "TRUE";
	}
	else {
		active = "FALSE";
	}
   	
	sql = 	"UPDATE gt_users SET\n" +
			"	login = '" + StringEscapeUtils.escapeSql(login) + "',\n" + 
			password + 
			"	active = " + active + ",\n" +
			"	initialized = TRUE\n" +
			"WHERE\n" +
			"	id = " + userId;
	db.update(sql);
   	
   	Permissions.updateUserPermissions(request, userId, groupId);
   	
	output.object();
	output.key("success").value(true);
	output.key("message").value("Usuário atualizado com sucesso.");
	output.endObject();
}
else if (action.equals("remove") && request.getParameter("id") != null) {
	String id = request.getParameter("id");
	
	sql = "DELETE FROM gt_users WHERE id = " + id; 
	db.update(sql);
	
	output.object();
	output.key("success").value(true);
	output.key("message").value("Usuário removido com sucesso.");
	output.endObject();
}
else {
	response.setStatus(400);
	
	output.object();
	output.key("success").value(false);
	output.key("message").value("Parâmetros incorretos");
	output.endObject();
}

db.close();
%>