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
	if (!Permissions.canWrite(session, "definitions_modules", response, out))
		return;
	
	String module_id = request.getParameter("module_id");
	String name = request.getParameter("name");
	
	sql = "INSERT INTO modules(module_id, name) VALUES (UPPER('" + StringEscapeUtils.escapeSql(module_id) + "'), '" + StringEscapeUtils.escapeSql(name) + "')";
	if (db.update(sql) > 0) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Módulo adicionado com sucesso.");
		output.endObject();
		
		logger.log("Inserção do módulo " + module_id, "Definições", "Módulos", "INSERT");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível adicionar o módulo. Verifique se o ID informado já existe.");
		output.endObject();
	}
}
else if (action.equals("edit") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_modules", response, out))
		return;
	
	String id = request.getParameter("id");
	String module_id = request.getParameter("module_id");
	String name = request.getParameter("name");
	
	sql = 	"UPDATE modules SET\n"+
			"	module_id = UPPER('" + StringEscapeUtils.escapeSql(module_id) + "'),\n"+
			"	name = '" + StringEscapeUtils.escapeSql(name) + "'\n" + 
			"WHERE module_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	
	if (db.update(sql) == 1) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Módulo atualizado com sucesso.");
		output.endObject();
		
		logger.log("Edição do módulo " + id + " para " + module_id, "Definições", "Módulos", "UPDATE");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível editar o módulo. Verifique se o ID informado já existe.");
		output.endObject();
	}
}
else if (action.equals("remove") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_modules", response, out))
		return;
	
	String id = request.getParameter("id");
	
	sql = "DELETE FROM modules_transactions WHERE module_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);
	
	sql = "DELETE FROM modules WHERE module_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);
	
	output.object();
	output.key("success").value(true);
	output.key("message").value("Módulo removido com sucesso.");
	output.endObject();
	
	logger.log("Remoção do módulo " + id + "." , "Definições", "Módulos", "DELETE");
}
else if (action.equals("checkConstraints") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_modules", response, out))
		return;
	
	String id = request.getParameter("id");
	ResultSet result;
	int sum = 0;
	boolean error = false;
	
	sql = "SELECT COUNT(*) AS num FROM modules_transactions WHERE module_id = '" + StringEscapeUtils.escapeSql(id) + "'";
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
else if (action.equals("addTransactions") && request.getParameter("transactions") != null && request.getParameter("module") != null) {
	if (!Permissions.canWrite(session, "definitions_modules", response, out))
		return;
	
	String module_id = request.getParameter("module");
	String transactions = request.getParameter("transactions");
	
	sql = "INSERT INTO modules_transactions(module_id, transaction_id) VALUES ";
	
	String[] transactionIds = transactions.split("@@");
	for (int i = 0; i < transactionIds.length; i++) {
		sql += "('" + StringEscapeUtils.escapeSql(module_id) + "', '" + StringEscapeUtils.escapeSql(transactionIds[i]) + "')";
		
		if (i < transactionIds.length - 1)
			sql += ",";
	}
	
	db.update(sql);
	output.object();
	output.key("success").value(true);
	output.endObject();
	
	logger.log("Acrescentando transações " + Utils.verboseStringList(transactionIds) + " ao módulo " + module_id + "." , "Definições", "Módulos", "INSERT");
}
else if (action.equals("removeTransactions") && request.getParameter("transactions") != null && request.getParameter("module") != null) {
	if (!Permissions.canWrite(session, "definitions_modules", response, out))
		return;
	
	String module_id = request.getParameter("module");
	String transactions = request.getParameter("transactions");
	
	sql = "DELETE FROM modules_transactions WHERE module_id = '" + StringEscapeUtils.escapeSql(module_id) + "' AND transaction_id IN (";
	
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
	
	logger.log("Removendo transações " + Utils.verboseStringList(transactionIds) + " do módulo " + module_id + "." , "Definições", "Módulos", "DELETE");
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