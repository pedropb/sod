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
ResultSet result;

if (action.equals("add")) {
	if (!Permissions.canWrite(session, "tools_snapshots", response, out))
		return;
	
	// limpando os aceites de usuários referente a conflitos que não existem mais
	sql = 	"SELECT\n" +
			"	ua.user_id, c.conflict_id\n" +
			"FROM\n" +
			"	conflicts c\n" +
			"	INNER JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON ua.activity_id = c.activity1\n" +
			"	INNER JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua2 ON ua2.activity_id = c.activity2\n" +
			"WHERE\n" +
			"	ua.user_id = ua2.user_id";
	
	sql = 	"DELETE FROM users_solutions\n" +
			"WHERE (user_id, conflict_id) NOT IN (" + sql + ")";
	
	db.update(sql);
	
	// limpando os aceites de grupos referente a conflitos que não existem mais
	sql = 	"SELECT\n" +
			"	ga.group_id, c.conflict_id\n" +
			"FROM\n" +
			"	conflicts c\n" +
			"	INNER JOIN groups_activities ga ON ga.activity_id = c.activity1\n" +
			"	INNER JOIN groups_activities ga2 ON ga2.activity_id = c.activity2\n" +
			"WHERE\n" +
			"	ga.group_id = ga2.group_id";
	
	sql = 	"DELETE FROM groups_solutions\n" +
			"WHERE (group_id, conflict_id) NOT IN (" + sql + ")";
	
	db.update(sql);
	
	sql = 	"SELECT\n" +
			"	COUNT(*)\n" +
			"FROM\n" +
			"	conflicts c\n" +
			"	INNER JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON ua.activity_id = c.activity1\n" +
			"	INNER JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua2 ON ua2.activity_id = c.activity2\n" +
			"WHERE\n" +
			"	ua.user_id = ua2.user_id";
	result = db.query(sql);
	result.next();
	int usersConflicts = result.getInt(1);
	
	sql = "SELECT COUNT(*) FROM users_solutions";
	result = db.query(sql);
	result.next();
	int acceptedUsersConflicts = result.getInt(1);
	
	sql = 	"SELECT\n" +
			"	COUNT(*)\n" +
			"FROM\n" +
			"	conflicts c\n" +
			"	INNER JOIN groups_activities ga ON ga.activity_id = c.activity1\n" +
			"	INNER JOIN groups_activities ga2 ON ga2.activity_id = c.activity2\n" +
			"WHERE\n" +
			"	ga.group_id = ga2.group_id";
	result = db.query(sql);
	result.next();
	int groupsConflicts = result.getInt(1);
	
	sql = "SELECT COUNT(*) FROM groups_solutions";
	result = db.query(sql);
	result.next();
	int acceptedGroupsConflicts = result.getInt(1);
	
	sql = 	"INSERT INTO snapshots(users_conflicts, accepted_users_conflicts, groups_conflicts, accepted_groups_conflicts)\n" + 
			"VALUES (" + usersConflicts + ", " + acceptedUsersConflicts + ", " + groupsConflicts + ", " + acceptedGroupsConflicts + ")";
	if (db.update(sql) > 0) {
		output.object();
		output.key("success").value(true);
		output.endObject();
		
		sql = "SELECT CURRVAL('snapshots_snapshot_id_seq')";
		result = db.query(sql);
		result.next();
		int id = result.getInt(1);
		
		logger.log(	"Geração do snapshot " + id + ".\n"+
					"Conflitos de usuários: " + usersConflicts + ".\n" +
					"Conflitos de usuários aceitos: " + acceptedUsersConflicts + ".\n" +
					"Conflitos de grupos: " + groupsConflicts + ".\n" +
					"Conflitos de grupos aceitos: " + acceptedGroupsConflicts + ".", "Ferramentas", "Snapshots", "INSERT");
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Ocorreram erros durante a geração do snapshot");
		output.endObject();
	}
}
else if (action.equals("remove") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "tools_snapshots", response, out))
		return;
	
	String id = request.getParameter("id");
	
	sql = "DELETE FROM snapshots WHERE snapshot_id = " + id;
	db.update(sql);
	
	output.object();
	output.key("success").value(true);
	output.endObject();
	
	logger.log("Remoção do snapshot " + id + ".", "Ferramentas", "Snapshots", "DELETE");
}
/*
	Ideia: dado um número de snapshot, apagar todos os snapshots
	anteriores, resetar a sequência e alterar os que ficaram
	para seguir a sequência.
*/
else if (action.equals("reset") && request.getParameter("keepFromId") != null) {
	String keepFromId = request.getParameter("keepFromId");
	if ((keepFromId.replaceAll("[0-9]", "")).equals("")) {
		db.setAutoCommit(false);
		sql = "DELETE FROM snapshots where snapshot_id < " + keepFromId;
		db.update(sql);

		sql = "ALTER SEQUENCE snapshots_snapshot_id_seq RESTART WITH 1";
		db.update(sql);

		sql = "UPDATE snapshots SET snapshot_id = nextval('snapshots_snapshot_id_seq')";
		db.update(sql);

		db.commit();
		out.println("Sucesso");
	}
	else {
		out.println("keepFromId deve ser um número.");
	}
}
else if (action.equals("testReset") && request.getParameter("keepFromId") != null) {
	String keepFromId = request.getParameter("keepFromId");
	if ((keepFromId.replaceAll("[0-9]", "")).equals("")) {
		sql = "select min(snapshot_id) as min, max(snapshot_id) as max FROM snapshots where snapshot_id < " + keepFromId;
		result = db.query(sql);

		String min, max;
		result.next();
		min = result.getString("min");
		max = result.getString("max");

		out.println("Serão apagados os Snapshots de " + min + " a " + max);

		sql = "select count(*) as num, count(*) + 1 as proximo from snapshots where snapshot_id >= " + keepFromId;
		result = db.query(sql);
		result.next();
		String num = result.getString("num");

		out.println("Os snapshots remanescentes serão renumerados de 1 até " + num);

		String proximo = result.getString("proximo");
		out.println("O próximo snapshot gerado terá o número " + proximo);
	}
	else {
		out.println("keepFromId deve ser um número.");
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