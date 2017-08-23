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
ResultSet result;
Logger logger = new Logger(session);
	
String sql;

if (action.equals("checkActivityConflict") && request.getParameter("ids") != null) {
	if (!Permissions.canWrite(session, "tools_create_groups", response, out))
		return;
	
	String[] ids = request.getParameter("ids").split("@@");
	String idSql = "";
	
	for (int i = 0; i < ids.length; i++) {
		if (i > 0) {
			idSql += ",";
		}
		
		idSql += "'" + StringEscapeUtils.escapeSql(ids[i]) + "'";
	}
	
	sql = 	"SELECT\n" +
			"	name\n" +
			"FROM\n" +
			"	conflicts\n" +
			"WHERE\n" +
			"	activity1 IN ("+ idSql +") AND activity2 IN ("+ idSql +")";
	
	result = db.query(sql);
	
	output.object();
	output.key("conflicts").array();
	boolean hasConflicts = false;
	while (result.next()) {
		output.value(result.getString("name"));
		hasConflicts = true;
	}
	output.endArray();
	output.key("hasConflicts").value(hasConflicts);
	output.key("success").value(true);
	output.endObject();
}
else if (action.equals("create") && request.getParameter("id") != null && request.getParameter("transactions") != null) {
	if (!Permissions.canWrite(session, "tools_create_groups", response, out))
		return;
	
	String id = request.getParameter("id");
	String name = request.getParameter("name");
	
	sql = "SELECT COUNT(*) FROM groups WHERE group_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	result = db.query(sql);
	result.next();
	if (result.getInt(1) > 0) {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Já existe um grupo com o ID \"" + id + "\". Utilize outro ID.");
		output.endObject();
		db.close();
		return;
	}
	
	boolean error = false;

	db.setAutoCommit(false);
	sql = "INSERT INTO groups(group_id, name) VALUES (UPPER('" + StringEscapeUtils.escapeSql(id) + "'), '" + StringEscapeUtils.escapeSql(name) + "')";
	error = (db.update(sql) != 1);
	
	// inserindo transações
	if (!error) {
		String[] ids = request.getParameter("transactions").split("@@");
		String idSql = "";
		
		for (int i = 0; i < ids.length; i++) {
			if (i > 0) {
				idSql += ",";
			}
			
			idSql += "('" + StringEscapeUtils.escapeSql(ids[i]) + "', '" + StringEscapeUtils.escapeSql(id) + "')";
		}
		
		sql = "INSERT INTO groups_transactions(transaction_id, group_id) VALUES "  + idSql;
		db.update(sql);
	}
	
	// inserindo usuários
	if (!error && request.getParameter("users") != null && request.getParameter("users").length() > 0) {
		String[] ids = request.getParameter("users").split("@@");
		String idSql = "";
		
		for (int i = 0; i < ids.length; i++) {
			if (i > 0) {
				idSql += ",";
			}
			
			idSql += "('" + StringEscapeUtils.escapeSql(ids[i]) + "', '" + StringEscapeUtils.escapeSql(id) + "')";
		}
		
		sql = "INSERT INTO users_groups(user_id, group_id) VALUES "  + idSql;
		db.update(sql);
	}
	
	output.object();
	output.key("success").value(!error);
	output.endObject();
	
	if (!error) {
		db.commit();
		
		String[] transactionIds = request.getParameter("transactions").split("@@");
		String userDescription = "";
		if (request.getParameter("users") != null) {
			userDescription = "\nUsuários: " + Utils.verboseStringList(request.getParameter("users").split("@@"));
		}
		logger.log("Criação do grupo " + id + " através do assistente de criação de grupos.\n Transações: " + Utils.verboseStringList(transactionIds) + "." + userDescription, "Ferramentas", "Grupos", "INSERT");
	}
	else {
		db.rollback();
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