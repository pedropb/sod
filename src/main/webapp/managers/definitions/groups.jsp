<%@page import="geotech.Utils"%>
<%@page import="geotech.Logger"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="geotech.Permissions"%>
<%@page import="org.json.JSONWriter"%>
<%@page import="geotech.Database"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%
String action = request.getParameter("action");

JSONWriter output = new JSONWriter(out);

if (action == null) {
	response.setStatus(400);
	
	output.object();
	output.key("success").value(false);
	output.key("message").value("Action é obrigatório");
	output.endObject();
	
	return;
}

Database db = new Database();
Logger logger = new Logger(session);
	
String sql;

if (action.equals("add")) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out))
		return;
	
	String group_id = request.getParameter("group_id");
	String name = request.getParameter("name");
	
	sql = "INSERT INTO groups(group_id, name) VALUES (UPPER('" + StringEscapeUtils.escapeSql(group_id) + "'), '" + StringEscapeUtils.escapeSql(name) + "')";
	if (db.update(sql) > 0) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Grupo adicionado com sucesso.");
		output.endObject();
		
		logger.log("Inserção do grupo " + group_id, "Definições", "Grupos", "INSERT");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível adicionar o grupo. Verifique se o ID informado já existe.");
		output.endObject();
	}
}
else if (action.equals("edit") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out))
		return;
	
	String id = request.getParameter("id");
	String group_id = request.getParameter("group_id");
	String name = request.getParameter("name");
	
	sql = 	"UPDATE groups SET\n"+
			"	group_id = UPPER('" + StringEscapeUtils.escapeSql(group_id) + "'),\n"+
			"	name = '" + StringEscapeUtils.escapeSql(name) + "'\n" + 
			"WHERE group_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	
	if (db.update(sql) == 1) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Grupo atualizado com sucesso.");
		output.endObject();
		
		logger.log("Edição do grupo " + id + " para " + group_id, "Definições", "Grupos", "UPDATE");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível editar o grupo. Verifique se o ID informado já existe.");
		output.endObject();
	}
}
else if (action.equals("remove") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out))
		return;
	
	String id = request.getParameter("id");
	
	sql = "DELETE FROM users_groups WHERE group_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	int affectedUsers = db.update(sql);
	
	sql = "DELETE FROM groups_transactions WHERE group_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);
	
	sql = "DELETE FROM groups WHERE group_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);
	
	output.object();
	output.key("success").value(true);
	output.key("message").value("Grupo removido com sucesso.");
	output.endObject();
	
	logger.log("Remoção do grupo " + id + ". " + affectedUsers + " usuários afetados." , "Definições", "Grupos", "DELETE");
}
else if (action.equals("checkConstraints") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out))
		return;
	
	String id = request.getParameter("id");
	ResultSet result;
	int sum = 0;
	boolean error = false;
	
	sql = "SELECT COUNT(*) AS num FROM users_groups WHERE group_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	result = db.query(sql);
	if (result.next()) {
		sum += result.getInt("num");
	}
	else {
		error = true;
	}
	
	if (!error) {
		output.object();
		output.key("success").value(true);
		output.key("count").value(sum);
		output.endObject();
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível verificar as restrições. Se o problema persistir, entre em contato com o administrador do sistema.");
		output.endObject();
	}
}
else if (action.equals("addUsers") && request.getParameter("group") != null && request.getParameter("users") != null) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out))
		return;
	
	String group_id = request.getParameter("group");
	String users = request.getParameter("users");
	
	sql = "INSERT INTO users_groups(group_id, user_id) VALUES ";
	
	String[] userIds = users.split("@@");
	for (int i = 0; i < userIds.length; i++) {
		sql += "('" + StringEscapeUtils.escapeSql(group_id) + "', '" + StringEscapeUtils.escapeSql(userIds[i]) + "')";
		
		if (i < userIds.length - 1)
			sql += ",";
	}
	
	db.update(sql);
	output.object();
	output.key("success").value(true);
	output.endObject();
	
	logger.log("Acrescentando usuários " + Utils.verboseStringList(userIds) + " ao grupo " + group_id + "." , "Definições", "Grupos", "INSERT");
}
else if (action.equals("removeUsers") && request.getParameter("group") != null && request.getParameter("users") != null) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out))
		return;
	
	String group_id = request.getParameter("group");
	String users = request.getParameter("users");
	
	sql = "DELETE FROM users_groups WHERE group_id = '" + StringEscapeUtils.escapeSql(group_id) + "' AND user_id IN (";
	
	String[] userIds = users.split("@@");
	for (int i = 0; i < userIds.length; i++) {
		sql += "'" + StringEscapeUtils.escapeSql(userIds[i]) + "'";
		
		if (i < userIds.length - 1)
			sql += ",";
	}
	sql += ")";
	
	db.update(sql);
	output.object();
	output.key("success").value(true);
	output.endObject();
	
	logger.log("Removendo usuários " + Utils.verboseStringList(userIds) + " do grupo " + group_id + "." , "Definições", "Grupos", "DELETE");
}
else if (action.equals("addTransactions") && request.getParameter("transactions") != null && request.getParameter("group") != null) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out))
		return;
	
	String group_id = request.getParameter("group");
	String transactions = request.getParameter("transactions");
	
	sql = "INSERT INTO groups_transactions(group_id, transaction_id) VALUES ";
	
	String[] transactionIds = transactions.split("@@");
	for (int i = 0; i < transactionIds.length; i++) {
		sql += "('" + StringEscapeUtils.escapeSql(group_id) + "', '" + StringEscapeUtils.escapeSql(transactionIds[i]) + "')";
		
		if (i < transactionIds.length - 1)
			sql += ",";
	}
	
	db.update(sql);
	output.object();
	output.key("success").value(true);
	output.endObject();
	
	logger.log("Acrescentando transações " + Utils.verboseStringList(transactionIds) + " ao grupo " + group_id + "." , "Definições", "Grupos", "INSERT");
}
else if (action.equals("removeTransactions") && request.getParameter("transactions") != null && request.getParameter("group") != null) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out))
		return;
	
	String group_id = request.getParameter("group");
	String transactions = request.getParameter("transactions");
	
	sql = "DELETE FROM groups_transactions WHERE group_id = '" + StringEscapeUtils.escapeSql(group_id) + "' AND transaction_id IN (";
	
	String[] transactionIds = transactions.split("@@");
	for (int i = 0; i < transactionIds.length; i++) {
		sql += "'" + StringEscapeUtils.escapeSql(transactionIds[i]) + "'";
		
		if (i < transactionIds.length - 1)
			sql += ",";
	}
	sql += ")";
	
	db.update(sql);
	output.object();
	output.key("success").value(true);
	output.endObject();
	
	logger.log("Removendo transações " + Utils.verboseStringList(transactionIds) + " do grupo " + group_id + "." , "Definições", "Grupos", "DELETE");
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