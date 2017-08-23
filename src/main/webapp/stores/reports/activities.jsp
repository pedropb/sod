<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "reports_transactions", response, out)){
	return;
}

if (request.getParameter("groupBy") == null) {
	Permissions.outputError(response, out);
	return;
}

String groupBy = request.getParameter("groupBy");

String detail = request.getParameter("detail");
String detailSql = "";
boolean hasDetail = false;
if (detail != null) {
	hasDetail = true;
}
else {
	detail = "";
	hasDetail = false;
}

String otherSql = "";

if (groupBy.equals("Usuário")) {
	sql = 	"SELECT\n" +
			"	u.user_id AS id,\n" +
			"	u.name AS name,\n" +
			"	COUNT(DISTINCT ua.activity_id) AS quantity\n" + 
			"FROM\n" +
			"	users u\n" +
			"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON u.user_id = ua.user_id\n" +
			"GROUP BY u.user_id, u.name\n" +
			"ORDER BY u.name";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ua.activity_id) AS quantity\n" + 
				"FROM\n" +
				"	(SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua\n" +
				"WHERE\n" +
				"	ua.user_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	a.activity_id AS id,\n" +
				"	a.name AS name\n" +
				"FROM\n" +
				"	(SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua\n" +
				"	INNER JOIN activities a ON ua.activity_id = a.activity_id\n" +
				"WHERE\n" +
				"	ua.user_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY a.activity_id";
}
else if (groupBy.equals("Grupo")) {
	sql = 	"SELECT\n" +
			"	g.group_id AS id,\n" +
			"	g.name AS name,\n" +
			"	COUNT(DISTINCT ga.activity_id) AS quantity\n" +  
			"FROM\n" +
			"	groups g\n" +
			"	LEFT JOIN groups_activities ga ON ga.group_id = g.group_id\n" +
			"GROUP BY g.group_id, g.name\n" +
			"ORDER BY g.name";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ga.activity_id) AS quantity\n" + 
				"FROM\n" +
				"	groups_activities ga\n" +
				"WHERE\n" +
				"	ga.group_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	a.activity_id AS id,\n" +
				"	a.name AS name\n" +
				"FROM\n" +
				"	groups_activities ga\n" +
				"	INNER JOIN activities a ON ga.activity_id = a.activity_id\n" +
				"WHERE\n" +
				"	ga.group_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY a.activity_id";
}
else if (groupBy.equals("Módulo")) {
	sql = 	"SELECT\n" +
			"	m.module_id AS id,\n" +
			"	m.name AS name,\n" +
			"	(SELECT COUNT(DISTINCT t.activity_id) FROM modules_transactions mt INNER JOIN transactions t ON t.transaction_id = mt.transaction_id WHERE mt.module_id = m.module_id) AS quantity\n" + 
			"FROM\n" +
			"	modules m\n" +
			"ORDER BY m.module_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT t.activity_id) AS quantity\n" + 
				"FROM\n" +
				"	transactions t\n" +
				"	INNER JOIN modules_transactions mt ON mt.transaction_id = t.transaction_id\n" +
				"WHERE\n" +
				"	mt.module_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	a.activity_id AS id,\n" +
				"	a.name AS name\n" +
				"FROM\n" +
				"	transactions t\n" +
				"	INNER JOIN modules_transactions mt ON mt.transaction_id = t.transaction_id\n" +
				"	INNER JOIN activities a ON t.activity_id = a.activity_id\n" +
				"WHERE\n" +
				"	mt.module_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY a.activity_id";
}
else {
	Permissions.outputError(response, out);
	return;
}

if (request.getParameter("chart") != null && request.getParameter("chart").equals("true")) {
	ExtStore.generateChartStore(sql, otherSql, request, out);
}
else if (hasDetail) {
	ExtStore.generateStore(detailSql, request, out);
}
else {
	ExtStore.generateStore(sql, request, out);
}

%>