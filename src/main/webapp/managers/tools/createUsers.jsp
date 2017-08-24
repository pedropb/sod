<%@page import="geotech.Logger"%>
<%@page import="geotech.Utils"%>
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
ResultSet result;
Logger logger = new Logger(session);
	
String sql;

if (action.equals("checkActivityConflict") && request.getParameter("ids") != null) {
	if (!Permissions.canWrite(session, "tools_create_users", response, out))
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
	if (!Permissions.canWrite(session, "tools_create_users", response, out))
		return;
	
	String id = request.getParameter("id");
	String name = request.getParameter("name");
	
	sql = "SELECT COUNT(*) FROM users WHERE user_id = '" + StringEscapeUtils.escapeSql(id) + "'";
	result = db.query(sql);
	result.next();
	if (result.getInt(1) > 0) {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Já existe um usuário com o ID \"" + id + "\". Utilize outro ID.");
		output.endObject();
		db.close();
		return;
	}
		
	boolean error = false;
	
	db.setAutoCommit(false);
	sql = "INSERT INTO users(user_id, name) VALUES (UPPER('" + StringEscapeUtils.escapeSql(id) + "'), '" + StringEscapeUtils.escapeSql(name) + "')";
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
		
		sql = "INSERT INTO users_transactions(transaction_id, user_id) VALUES "  + idSql;
		db.update(sql);
	}
	
	// inserindo grupos
	if (!error && request.getParameter("groups") != null && request.getParameter("groups").length() > 0) {
		String[] ids = request.getParameter("groups").split("@@");
		String idSql = "";
		
		for (int i = 0; i < ids.length; i++) {
			if (i > 0) {
				idSql += ",";
			}
			
			idSql += "('" + StringEscapeUtils.escapeSql(ids[i]) + "', '" + StringEscapeUtils.escapeSql(id) + "')";
		}
		
		sql = "INSERT INTO users_groups(group_id, user_id) VALUES "  + idSql;
		db.update(sql);
	}
	
	output.object();
	output.key("success").value(!error);
	output.endObject();
	
	if (!error) {
		db.commit();
		
		String[] transactionIds = request.getParameter("transactions").split("@@");
		String groupDescription = "";
		if (request.getParameter("groups") != null) {
			groupDescription = "\nGrupos: " + Utils.verboseStringList(request.getParameter("groups").split("@@"));
		}
		logger.log("Criação do usuário " + id + " através do assistente de criação de usuários.\n Transações: " + Utils.verboseStringList(transactionIds) + "." + groupDescription, "Ferramentas", "Usuários", "INSERT");
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