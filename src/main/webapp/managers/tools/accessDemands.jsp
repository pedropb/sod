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
ResultSet result;

String userId = (String) session.getAttribute("userId");

if (action.equals("add")) {
	if (!Permissions.canWrite(session, "tools_my_access_demands", response, out))
		return;
	
	String user_name = request.getParameter("user_name");
	String real_name = request.getParameter("real_name");
	String demand_type = request.getParameter("demand_type");
	String obs = request.getParameter("obs");
	String copy_user_id = request.getParameter("copy_user_id"); 
	
	if (copy_user_id != null) {
		sql = 	"INSERT INTO access_demands(applicant_id, status, user_name, real_name, obs, demand_type, copy_user_id) VALUES \n" +
				"(" +
				"	'" + userId + "',\n" +
				"	'Em análise',\n" +
				"	'" + StringEscapeUtils.escapeSql(user_name) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(real_name) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(obs) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(demand_type) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(copy_user_id) + "'\n" +
				")";
		
		if (db.update(sql) == 1) {
			output.object();
			output.key("success").value(true);
			output.key("message").value("Solicitação de acesso cadastrada.");
			output.endObject();
			
			logger.log("Criação da solicitação de acesso para " + real_name + " (" + user_name + ").", "Ferramentas", "Solicitação de acesso", "INSERT");
		}
		else {
			output.object();
	 		output.key("success").value(false);
	 		output.key("message").value("Ocorreram erros durante a criação da solicitação de acesso");
	 		output.endObject();
		}
	}
	else {
		String group1 = request.getParameter("group1");
		String group2 = request.getParameter("group2");
		String group3 = request.getParameter("group3");
		
		String[] access_level = new String[]{"", "", ""};
		
		for (int i=1; i <= 3; i++) {
			if (request.getParameter("list" + i) != null) {
				access_level[i-1] += "C";
			}
			
			if (request.getParameter("include" + i) != null) {
				access_level[i-1] += "I";
			}
			
			if (request.getParameter("change" + i) != null) {
				access_level[i-1] += "A";
			}
			
			if (request.getParameter("remove" + i) != null) {
				access_level[i-1] += "E";
			}
		}
		
		sql = 	"INSERT INTO access_demands(applicant_id, status, user_name, real_name, obs, demand_type, group1, access_level1, group2, access_level2, group3, access_level3) VALUES \n" +
				"(" +
				"	'" + userId + "',\n" +
				"	'Em análise',\n" +
				"	'" + StringEscapeUtils.escapeSql(user_name) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(real_name) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(obs) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(demand_type) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(group1) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(access_level[0]) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(group2) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(access_level[1]) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(group3) + "',\n" +
				"	'" + StringEscapeUtils.escapeSql(access_level[2]) + "'\n" +
				")";
		
		if (db.update(sql) == 1) {
			output.object();
			output.key("success").value(true);
			output.key("message").value("Solicitação de acesso cadastrada.");
			output.endObject();
			
			logger.log("Criação da solicitação de acesso para " + real_name + " (" + user_name + ").", "Ferramentas", "Solicitação de acesso", "INSERT");
		}
		else {
			output.object();
	 		output.key("success").value(false);
	 		output.key("message").value("Ocorreram erros durante a criação da solicitação de acesso");
	 		output.endObject();
		}
	}
}
else if (action.equals("remove") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "tools_my_access_demands", response, out))
		return;
	
	String id = request.getParameter("id");
	
	sql = "DELETE FROM access_demands WHERE demand_id = " + id + " AND applicant_id = " + userId;
	db.update(sql);
	
	output.object();
	output.key("success").value(true);
	output.endObject();
	
	logger.log("Remoção da solicitação de acesso " + id + ".", "Ferramentas", "Solicitação de acesso", "DELETE");
}
else if (action.equals("analyze_conflicts")) {
	if (!Permissions.canWrite(session, "tools_access_demands", response, out))
		return;
	
	String copy_user_id = request.getParameter("copy_user_id");
	
	if (copy_user_id != null && copy_user_id.length() > 0) {
		// Analyze on user
		
		sql = 	"SELECT\n" +
				"	c.name AS name\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"	INNER JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON ua.activity_id = c.activity1\n" +
				"	INNER JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua2 ON ua2.activity_id = c.activity2\n" +
				"WHERE\n" +
				"	ua.user_id = ua2.user_id AND ua.user_id = '" + StringEscapeUtils.escapeSql(copy_user_id) + "'\n" +
				"ORDER BY c.conflict_id";
		
		
		result = db.query(sql);
		if (result != null) {
			String analysis = "";
			int conflictCount = 0;
			
			while (result.next()) {
				if (conflictCount > 0) {
					analysis += "\n";
				}
				
				analysis += result.getString("name");
				conflictCount++;
			}
			
			if (conflictCount == 0) {
				analysis = "Nenhum conflito foi encontrado.";
			}
			else {
				analysis = conflictCount + " conflito(s) encontrado(s):\n" + analysis;
			}
			
			output.object();
			output.key("success").value(true);
			output.key("analysis").value(analysis);
			output.endObject();
		}
		else {
			output.object();
			output.key("success").value(false);
			output.key("message").value("Ocorreram erros enquanto analisava conflitos.");
			output.endObject();
		}
	}
	else {
		// Analyze on group
		
		String group1 = request.getParameter("group1");
		String group2 = request.getParameter("group2");
		String group3 = request.getParameter("group3");
		
		String groupArray = "";
		boolean comma = false;
		
		if (group1 != null && group1.length() > 0) {
			groupArray = "'" + StringEscapeUtils.escapeSql(group1) + "'";
			comma = true;
		}
		
		if (group2 != null && group2.length() > 0) {
			if (comma)
				groupArray += ",";
			
			groupArray += "'" + StringEscapeUtils.escapeSql(group2) + "'";
			comma = true;
		}
		
		if (group3 != null && group3.length() > 0) {
			if (comma)
				groupArray += ",";
			
			groupArray += "'" + StringEscapeUtils.escapeSql(group3) + "'";
			comma = true;
		}
		
		if (groupArray.length() > 0) {
			sql = 	"SELECT\n" +
					"	c.name AS name\n" +
					"FROM\n" +
					"	conflicts c\n" +
					"	INNER JOIN groups_activities ga1 ON ga1.activity_id = c.activity1\n" +
					"	INNER JOIN groups_activities ga2 ON ga2.activity_id = c.activity2\n" +
					"WHERE\n" +
					"	ga1.group_id IN ("+ groupArray +") AND ga2.group_id IN ("+ groupArray +")\n" +
					"ORDER BY c.conflict_id";
			
			result = db.query(sql);
			if (result != null) {
				String analysis = "";
				int conflictCount = 0;
				
				while (result.next()) {
					if (conflictCount > 0) {
						analysis += "\n";
					}
					
					analysis += result.getString("name");
					conflictCount++;
				}
				
				if (conflictCount == 0) {
					analysis = "Nenhum conflito foi encontrado.";
				}
				else {
					analysis = conflictCount + " conflito(s) encontrado(s):\n" + analysis;
				}
				
				output.object();
				output.key("success").value(true);
				output.key("analysis").value(analysis);
				output.endObject();
			}
			else {
				output.object();
				output.key("success").value(false);
				output.key("message").value("Ocorreram erros enquanto analisava conflitos.");
				output.endObject();
			}
		}
		else {
			output.object();
			output.key("success").value(false);
			output.key("message").value("Ocorreram erros enquanto analisava conflitos. Nenhum grupo foi informado.");
			output.endObject();
		}
	}
}
else if (action.equals("approve") && request.getParameter("id") != null) {
	if (!Permissions.canWrite(session, "tools_access_demands", response, out))
		return;
	
	String id = request.getParameter("id");
	String reason = request.getParameter("reason") != null && request.getParameter("reason").length() > 0 ?
					"'" + StringEscapeUtils.escapeSql(request.getParameter("reason")) + "'"
					: "NULL";
	String status = request.getParameter("status");
	
	sql = 	"UPDATE access_demands SET \n" + 
			"	approver_id = " + userId + ",\n" +
			"	reason = " + reason + ",\n" +
			"	updated = NOW(),\n" +
			"	status = '" + StringEscapeUtils.escapeSql(status) + "'\n" +
			"WHERE demand_id = " + id;
	
	db.update(sql);
	
	output.object();
	output.key("success").value(true);
	output.key("message").value("Status da solicitação alterado com sucesso.");
	output.endObject();
	
	logger.log("Alteração do status solicitação de acesso " + id + " para \"" + status + "\".", "Ferramentas", "Solicitação de acesso", "UPDATE");
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