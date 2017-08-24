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
	if (!Permissions.canWrite(session, "definitions_activities", response, out))
		return;

	String activity_id = request.getParameter("activity_id");
	String name = request.getParameter("name");

	sql = "INSERT INTO activities(activity_id, name) VALUES (UPPER('" + StringEscapeUtils.escapeSql(activity_id) + "'), '" + StringEscapeUtils.escapeSql(name) + "')";
	if (db.update(sql) > 0) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Atividade adicionada com sucesso.");
		output.endObject();

		logger.log("Inserção da atividade " + activity_id, "Definições", "Atividades", "INSERT");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível adicionar a atividade. Verifique se o ID informado já existe.");
		output.endObject();
	}
}
else if (action.equals("edit") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_activities", response, out))
		return;

	String id = request.getParameter("id");
	String activity_id = request.getParameter("activity_id");
	String name = request.getParameter("name");

	sql = 	"UPDATE activities SET\n"+
			"	activity_id = UPPER('" + StringEscapeUtils.escapeSql(activity_id) + "'),\n"+
			"	name = '" + StringEscapeUtils.escapeSql(name) + "'\n" +
			"WHERE activity_id = '" + StringEscapeUtils.escapeSql(id) + "'";

	if (db.update(sql) == 1) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Atividade atualizada com sucesso.");
		output.endObject();

		logger.log("Edição da atividade " + id + " para "+ activity_id, "Definições", "Atividades", "UPDATE");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível editar a atividade. Verifique se o ID informado já existe.");
		output.endObject();
	}

}
else if (action.equals("remove") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_activities", response, out))
		return;

	String id = request.getParameter("id");

	sql = "UPDATE transactions SET activity_id = NULL WHERE activity_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	int affectedTransactions = db.update(sql);

	sql = "DELETE FROM conflicts WHERE activity1 = '" + StringEscapeUtils.escapeSql(id) + "' OR activity2 = '" + StringEscapeUtils.escapeSql(id) + "'";
	int affectedConflicts = db.update(sql);

	sql = "DELETE FROM activities WHERE activity_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);

	output.object();
	output.key("success").value(true);
	output.key("message").value("Atividade removida com sucesso.");
	output.endObject();

	logger.log("Remoção da atividade " + id + ". " + affectedTransactions + " transações afetadas. " + affectedConflicts + " conflitos afetados." , "Definições", "Atividades", "DELETE");
}
else if (action.equals("checkConstraints") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_activities", response, out))
		return;

	String id = request.getParameter("id");
	ResultSet result;
	int sum = 0;
	boolean error = false;

	sql = "SELECT COUNT(*) AS num FROM transactions WHERE activity_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	result = db.query(sql);
	if (result.next()) {
		sum += result.getInt("num");
	}
	else {
		error = true;
	}

	sql = "SELECT COUNT(*) AS num FROM conflicts WHERE activity1 = '" + StringEscapeUtils.escapeSql(id) + "' OR activity2 = '" + StringEscapeUtils.escapeSql(id) + "'";
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
else if (action.equals("addTransactions") && request.getParameter("transactions") != null && request.getParameter("activity") != null) {
	if (!Permissions.canWrite(session, "definitions_activities", response, out))
		return;

	String activity_id = request.getParameter("activity");
	String transactions = request.getParameter("transactions");

	sql = "UPDATE transactions SET activity_id = '" + StringEscapeUtils.escapeSql(activity_id) + "' WHERE transaction_id IN (";

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

	logger.log("Definindo transações " + Utils.verboseStringList(transactionIds) + " como sendo da atividade " + activity_id + "." , "Definições", "Atividades", "UPDATE");
}
else if (action.equals("removeTransactions") && request.getParameter("transactions") != null && request.getParameter("activity") != null) {
	if (!Permissions.canWrite(session, "definitions_activities", response, out))
		return;

	String activity_id = request.getParameter("activity");
	String transactions = request.getParameter("transactions");

	sql = "UPDATE transactions SET activity_id = NULL WHERE transaction_id IN (";

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

	logger.log("Removendo transações " + Utils.verboseStringList(transactionIds) + " da atividade " + activity_id + "." , "Definições", "Atividades", "DELETE");
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
