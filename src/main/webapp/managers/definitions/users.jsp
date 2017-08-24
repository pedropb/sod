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

Database db = Database.createDatabase();
Logger logger = new Logger(session);

String sql;

if (action.equals("add")) {
	if (!Permissions.canWrite(session, "definitions_users", response, out))
		return;

	String user_id = request.getParameter("user_id");
	String name = request.getParameter("name");

	sql = "INSERT INTO users(user_id, name) VALUES (UPPER('" + StringEscapeUtils.escapeSql(user_id) + "'), '" + StringEscapeUtils.escapeSql(name) + "')";
	if (db.update(sql) > 0) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Usuário adicionado com sucesso.");
		output.endObject();

		logger.log("Inserção do usuário " + user_id, "Definições", "Usuários", "INSERT");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível adicionar o usuário. Verifique se o ID informado já existe.");
		output.endObject();
	}
}
else if (action.equals("edit") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_users", response, out))
		return;

	String id = request.getParameter("id");
	String user_id = request.getParameter("user_id");
	String name = request.getParameter("name");

	sql = 	"UPDATE users SET\n"+
			"	user_id = UPPER('" + StringEscapeUtils.escapeSql(user_id) + "'),\n"+
			"	name = '" + StringEscapeUtils.escapeSql(name) + "'\n" +
			"WHERE user_id = '" + StringEscapeUtils.escapeSql(id) + "'";

	if (db.update(sql) == 1) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Usuário atualizado com sucesso.");
		output.endObject();

		logger.log("Edição do usuário " + id + " para " + user_id, "Definições", "Usuários", "UPDATE");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível editar o usuário. Verifique se o ID informado já existe.");
		output.endObject();
	}
}
else if (action.equals("remove") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_users", response, out))
		return;

	String id = request.getParameter("id");

	sql = "DELETE FROM users_groups WHERE user_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);

	sql = "DELETE FROM users_transactions WHERE user_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);

	sql = "DELETE FROM users WHERE user_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);

	output.object();
	output.key("success").value(true);
	output.key("message").value("Usuário removido com sucesso.");
	output.endObject();

	logger.log("Remoção do usuário " + id + "." , "Definições", "Usuários", "DELETE");
}
else if (action.equals("checkConstraints") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_users", response, out))
		return;

	String id = request.getParameter("id");
	ResultSet result;
	int sum = 0;
	boolean error = false;

	sql = "SELECT COUNT(*) AS num FROM users_groups WHERE user_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	result = db.query(sql);
	if (result.next()) {
		sum += result.getInt("num");
	}
	else {
		error = true;
	}

	sql = "SELECT COUNT(*) AS num FROM users_transactions WHERE user_id = '" + StringEscapeUtils.escapeSql(id) + "'";
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
else if (action.equals("addGroups") && request.getParameter("groups") != null && request.getParameter("user") != null) {
	if (!Permissions.canWrite(session, "definitions_users", response, out))
		return;

	String user_id = request.getParameter("user");
	String groups = request.getParameter("groups");

	sql = "INSERT INTO users_groups(user_id, group_id) VALUES ";

	String[] groupIds = groups.split("@@");
	for (int i = 0; i < groupIds.length; i++) {
		sql += "('" + StringEscapeUtils.escapeSql(user_id) + "', '" + StringEscapeUtils.escapeSql(groupIds[i]) + "')";

		if (i < groupIds.length - 1)
			sql += ",";
	}

	db.update(sql);
	output.object();
	output.key("success").value(true);
	output.endObject();

	logger.log("Acrescentando grupos " + Utils.verboseStringList(groupIds) + " ao usuário " + user_id + "." , "Definições", "Usuários", "INSERT");
}
else if (action.equals("removeGroups") && request.getParameter("groups") != null && request.getParameter("user") != null) {
	if (!Permissions.canWrite(session, "definitions_users", response, out))
		return;

	String user_id = request.getParameter("user");
	String groups = request.getParameter("groups");

	sql = "DELETE FROM users_groups WHERE user_id = '" + StringEscapeUtils.escapeSql(user_id) + "' AND group_id IN (";

	String[] groupIds = groups.split("@@");
	for (int i = 0; i < groupIds.length; i++) {
		sql += "'" + StringEscapeUtils.escapeSql(groupIds[i]) + "'";

		if (i < groupIds.length - 1)
			sql += ",";
	}
	sql += ")";

	db.update(sql);
	output.object();
	output.key("success").value(true);
	output.endObject();

	logger.log("Removendo grupos " + Utils.verboseStringList(groupIds) + " do usuário " + user_id + "." , "Definições", "Usuários", "DELETE");
}
else if (action.equals("addTransactions") && request.getParameter("transactions") != null && request.getParameter("user") != null) {
	if (!Permissions.canWrite(session, "definitions_users", response, out))
		return;

	String user_id = request.getParameter("user");
	String transactions = request.getParameter("transactions");

	String[] transactionIds = transactions.split("@@");
	for (int i = 0; i < transactionIds.length; i++) {
		sql = "INSERT INTO users_transactions(user_id, transaction_id) VALUES ('" + StringEscapeUtils.escapeSql(user_id) + "', '" + StringEscapeUtils.escapeSql(transactionIds[i]) + "')";
		db.update(sql);
	}

	output.object();
	output.key("success").value(true);
	output.endObject();

	logger.log("Acrescentando transações " + Utils.verboseStringList(transactionIds) + " ao usuário " + user_id + "." , "Definições", "Usuários", "INSERT");
}
else if (action.equals("removeTransactions") && request.getParameter("transactions") != null && request.getParameter("user") != null) {
	if (!Permissions.canWrite(session, "definitions_users", response, out))
		return;

	String user_id = request.getParameter("user");
	String transactions = request.getParameter("transactions");

	sql = "DELETE FROM users_transactions WHERE user_id = '" + StringEscapeUtils.escapeSql(user_id) + "' AND transaction_id IN (";

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

	logger.log("Removendo transações " + Utils.verboseStringList(transactionIds) + " do usuário " + user_id + "." , "Definições", "Usuários", "DELETE");
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
