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

Database db = Database.createDatabase();
Logger logger = new Logger(session);
	
String sql;

if (action.equals("add")) {
	if (!Permissions.canWrite(session, "definitions_transactions", response, out))
		return;
	
	String transaction_id = request.getParameter("transaction_id");
	String name = request.getParameter("name");
	String activity_id = request.getParameter("activity_id");
	
	sql = 	"INSERT INTO transactions(transaction_id, name, activity_id)\n" +
			"VALUES (UPPER('" + StringEscapeUtils.escapeSql(transaction_id) + "'), '" + StringEscapeUtils.escapeSql(name) + "', '" + StringEscapeUtils.escapeSql(activity_id) + "')";
	
	if (db.update(sql) > 0) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Transação adicionada com sucesso.");
		output.endObject();
		
		logger.log("Inserção da transação " + transaction_id, "Definições", "Transações", "INSERT");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível adicionar a transação. Verifique se o ID informado já existe.");
		output.endObject();
	}
}
else if (action.equals("edit") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_transactions", response, out))
		return;
	
	String id = request.getParameter("id");
	String transaction_id = request.getParameter("transaction_id");
	String name = request.getParameter("name");
	String activity_id = request.getParameter("activity_id");
	
	sql = 	"UPDATE transactions SET\n"+
			"	transaction_id = UPPER('" + StringEscapeUtils.escapeSql(transaction_id) + "'),\n"+
			"	name = '" + StringEscapeUtils.escapeSql(name) + "',\n" +
			"	activity_id = '" + StringEscapeUtils.escapeSql(activity_id) + "'\n" +
			"WHERE transaction_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	
	if (db.update(sql) == 1) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Transação atualizada com sucesso.");
		output.endObject();
		
		logger.log("Edição da transação " + id + " para " + transaction_id + " atividade " + activity_id + ".", "Definições", "Transações", "UPDATE");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível editar a transação. Verifique se o ID informado já existe.");
		output.endObject();
	}
	
}
else if (action.equals("remove") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_transactions", response, out))
		return;
	
	String id = request.getParameter("id");
	
	sql = "DELETE FROM users_transactions WHERE transaction_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);
	
	sql = "DELETE FROM groups_transactions WHERE transaction_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);
	
	sql = "DELETE FROM modules_transactions WHERE transaction_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);
	
	sql = "DELETE FROM transactions WHERE transaction_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);
	
	output.object();
	output.key("success").value(true);
	output.key("message").value("Transação removida com sucesso.");
	output.endObject();
	
	logger.log("Remoção da transação " + id + ".", "Definições", "Transações", "DELETE");
}
else if (action.equals("checkConstraints") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_transactions", response, out))
		return;
	
	String id = request.getParameter("id");
	ResultSet result;
	int sum = 0;
	boolean error = false;
	
	sql = "SELECT COUNT(*) AS num FROM users_transactions WHERE transaction_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	result = db.query(sql);
	if (result.next()) {
		sum += result.getInt("num");
	}
	else {
		error = true;
	}
	
	sql = "SELECT COUNT(*) AS num FROM groups_transactions WHERE transaction_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	result = db.query(sql);
	if (result.next()) {
		sum += result.getInt("num");
	}
	else {
		error = true;
	}
	
	sql = "SELECT COUNT(*) AS num FROM modules_transactions WHERE transaction_id = '" + StringEscapeUtils.escapeSql(id) + "'";
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
else {
	response.setStatus(400);
	
	output.object();
	output.key("success").value(false);
	output.key("message").value("Parâmetros incorretos");
	output.endObject();
}

db.close();
%>