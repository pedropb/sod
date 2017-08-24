<%@page import="geotech.Logger"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="geotech.Permissions"%>
<%@page import="org.json.JSONWriter"%>
<%@page import="geotech.Database"%>
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
	if (!Permissions.canWrite(session, "definitions_conflicts", response, out))
		return;
	
	String conflict_id = request.getParameter("conflict_id");
	String name = request.getParameter("name");
	String activity1 = request.getParameter("activity1");
	String activity2 = request.getParameter("activity2");
	
	sql = 	"INSERT INTO conflicts(conflict_id, activity1, activity2, name) \n" +
			"VALUES (UPPER('" + StringEscapeUtils.escapeSql(conflict_id) + "'),\n" +
					"'" + StringEscapeUtils.escapeSql(activity1) + "',\n" +
					"'" + StringEscapeUtils.escapeSql(activity2) + "',\n" +
					"'" + StringEscapeUtils.escapeSql(name) + "')";
	
	if (db.update(sql) > 0) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Conflito adicionado com sucesso.");
		output.endObject();
		
		logger.log("Inserção do conflito " + conflict_id, "Definições", "Conflitos", "INSERT");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível adicionar o conflito. Verifique se o ID informado já existe.");
		output.endObject();
	}
}
else if (action.equals("edit") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_conflicts", response, out))
		return;
	
	String id = request.getParameter("id");
	String conflict_id = request.getParameter("conflict_id");
	String name = request.getParameter("name");
	String activity1 = request.getParameter("activity1");
	String activity2 = request.getParameter("activity2");
	
	sql = 	"UPDATE conflicts SET\n"+
			"	conflict_id = UPPER('" + StringEscapeUtils.escapeSql(conflict_id) + "'),\n"+
			"	activity1 = '" + StringEscapeUtils.escapeSql(activity1) + "',\n"+
			"	activity2 = '" + StringEscapeUtils.escapeSql(activity2) + "',\n"+
			"	name = '" + StringEscapeUtils.escapeSql(name) + "'\n" + 
			"WHERE conflict_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	
	if (db.update(sql) == 1) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Conflito atualizado com sucesso.");
		output.endObject();
		
		logger.log("Edição do conflito " + id + " para " + conflict_id, "Definições", "Conflitos", "UPDATE");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível editar o conflito. Verifique se o ID informado já existe.");
		output.endObject();
	}
}
else if (action.equals("remove") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "definitions_conflicts", response, out))
		return;
	
	String id = request.getParameter("id");
	
	sql = "DELETE FROM conflicts WHERE conflict_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	db.update(sql);
	
	output.object();
	output.key("success").value(true);
	output.key("message").value("Conflito removido com sucesso.");
	output.endObject();
	
	logger.log("Remoção do conflito " + id + "." , "Definições", "Conflitos", "DELETE");
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