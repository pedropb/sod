<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "reports_conflicts", response, out)){
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
			"	COUNT(DISTINCT c.conflict_id) AS quantity\n" + 
			"FROM\n" +
			"	users u\n" +
			"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON ua.user_id = u.user_id\n" +
			"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua2 ON ua2.user_id = u.user_id\n" +
			"	LEFT JOIN conflicts c ON c.activity1 = ua.activity_id AND c.activity2 = ua2.activity_id\n" +
			"GROUP BY u.user_id, u.name\n" +
			"ORDER BY u.user_id, u.name";
	
	otherSql = 	"SELECT\n" + 
				"	COUNT(DISTINCT c.conflict_id) AS quantity\n" +
				"FROM\n" +
				"	users u\n" +
				"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON ua.user_id = u.user_id\n" +
				"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua2 ON ua2.user_id = u.user_id\n" +
				"	LEFT JOIN conflicts c ON c.activity1 = ua.activity_id AND c.activity2 = ua2.activity_id\n" +
				"WHERE\n" +
				"	u.user_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	c.conflict_id AS id,\n" +
				"	c.name AS name\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"	INNER JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON ua.activity_id = c.activity1\n" +
				"	INNER JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua2 ON ua2.activity_id = c.activity2\n" +
				"WHERE\n" +
				"	ua.user_id = ua2.user_id AND ua.user_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id";
}
else if (groupBy.equals("Grupo")) {
	sql = 	"SELECT\n" +
			"	g.group_id AS id,\n" +
			"	g.name AS name,\n" +
			"	COUNT(DISTINCT c.conflict_id) AS quantity\n" + 
			"FROM\n" +
			"	groups g\n" +
			"	LEFT JOIN groups_activities ga ON ga.group_id = g.group_id\n" +
			"	LEFT JOIN groups_activities ga2 ON ga2.group_id = g.group_id\n" +
			"	LEFT JOIN conflicts c ON c.activity1 = ga.activity_id AND c.activity2 = ga2.activity_id\n" +
			"GROUP BY g.group_id, g.name\n" +
			"ORDER BY g.group_id, g.name";
	
	otherSql = 	"SELECT\n" + 
				"	COUNT(DISTINCT c.conflict_id) AS quantity\n" +
				"FROM\n" +
				"	groups g\n" +
				"	LEFT JOIN groups_activities ga ON ga.group_id = g.group_id\n" +
				"	LEFT JOIN groups_activities ga2 ON ga2.group_id = g.group_id\n" +
				"	LEFT JOIN conflicts c ON c.activity1 = ga.activity_id AND c.activity2 = ga2.activity_id\n" +
				"WHERE\n" +
				"	g.group_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	c.conflict_id AS id,\n" +
				"	c.name AS name\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"	INNER JOIN groups_activities ga ON ga.activity_id = c.activity1\n" +
				"	INNER JOIN groups_activities ga2 ON ga2.activity_id = c.activity2\n" +
				"WHERE\n" +
				"	ga.group_id = ga2.group_id AND ga.group_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id";
}
else if (groupBy.equals("Atividade")) {
	sql = 	"SELECT\n" +
			"	a.activity_id AS id,\n" +
			"	a.name,\n" +
			"	COUNT(c.conflict_id) AS quantity\n" +
			"FROM\n" +
			"	activities a \n "+ 
			"	LEFT JOIN conflicts c ON a.activity_id = c.activity1 OR a.activity_id = c.activity2\n" +
			"GROUP BY a.activity_id, a.name\n" +
			"ORDER BY a.activity_id";
			
	otherSql = 	"SELECT\n" +
				"	COUNT(*) AS quantity\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"WHERE\n" +
				"	c.activity1 NOT IN (%TOP_ENTRIES%) AND c.activity2 NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	c.conflict_id AS id,\n" +
				"	c.name AS name\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"WHERE c.activity1 = '" + StringEscapeUtils.escapeSql(detail) + "' OR c.activity2 = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id";
}
else if (groupBy.equals("Módulo")) {
	String sqlAux = "SELECT\n" +
					"	t.activity_id\n" +
					"FROM\n" +
					"	transactions t\n" +
					"	INNER JOIN modules_transactions mt ON mt.transaction_id = t.transaction_id\n" +
					"WHERE\n" +
					"	mt.module_id = m.module_id";

	sql = 	"SELECT\n" +
			"	m.module_id AS id,\n" +
			"	m.name AS name,\n" +
			"	(SELECT COUNT(DISTINCT conflict_id) FROM conflicts WHERE activity1 IN ("+ sqlAux +") AND activity2 IN ("+ sqlAux +")) AS quantity\n" + 
			"FROM\n" +
			"	modules m\n" +
			"ORDER BY m.name";
	
	sql = 	"SELECT\n" +
			"	m.module_id AS id,\n" +
			"	m.name AS name,\n" +
			"	(SELECT COUNT(DISTINCT conflict_id) FROM conflicts WHERE activity1 IN ("+ sqlAux +") AND activity2 IN ("+ sqlAux +")) AS quantity\n" + 
			"FROM\n" +
			"	modules m\n" +
			"ORDER BY m.module_id";
	
	String otherSqlAux = 	"SELECT DISTINCT\n" +
						"	c.conflict_id,\n" +
						"	m.module_id\n" +
						"FROM\n" +
						"	conflicts c,\n" +
						"	modules m\n" +
						"WHERE\n" +
						"	c.activity1 IN ("+ sqlAux +")\n" +
						"	AND c.activity2 IN ("+ sqlAux +")";
	
	otherSql = 	"SELECT\n" + 
				"	COUNT(DISTINCT t.conflict_id) AS quantity\n" +
				"FROM\n" +
				"	(" + otherSqlAux + ") t\n" +
				"WHERE\n" +
				"	t.module_id NOT IN (%TOP_ENTRIES%)";
	
	String detailSqlAux = 	"SELECT\n" +
							"	t.activity_id\n" +
							"FROM\n" +
							"	transactions t\n" +
							"	INNER JOIN modules_transactions mt ON mt.transaction_id = t.transaction_id\n" +
							"WHERE\n" +
							"	mt.module_id = '" + StringEscapeUtils.escapeSql(detail) + "'";
	
	detailSql = "SELECT\n" +
				"	c.conflict_id AS id,\n" +
				"	c.name AS name\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"	INNER JOIN (" + detailSqlAux + ") ma1 ON ma1.activity_id = c.activity1\n" +
				"	INNER JOIN (" + detailSqlAux + ") ma2 ON ma2.activity_id = c.activity2\n" +
				"ORDER BY c.conflict_id";
}
else if (groupBy.equals("Transação")) {
	sql = 	"SELECT\n" +
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	COUNT(c.*) AS quantity\n" +
			"FROM\n" +
			"	transactions t \n "+
			"	LEFT JOIN activities a ON a.activity_id = t.activity_id\n" +
			"	LEFT JOIN conflicts c ON a.activity_id = c.activity1 OR a.activity_id = c.activity2\n" +
			"GROUP BY t.transaction_id, t.name\n" +
			"ORDER BY t.transaction_id";
			
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT conflict_id) AS quantity\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"	INNER JOIN activities a ON a.activity_id = c.activity1 OR a.activity_id = c.activity2\n" +
				"	INNER JOIN transactions t ON a.activity_id = t.activity_id\n" +
				"WHERE\n" +
				"	t.transaction_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	c.conflict_id AS id,\n" +
				"	c.name AS name\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"	INNER JOIN activities a ON a.activity_id = c.activity1 OR a.activity_id = c.activity2\n" +
				"	INNER JOIN transactions t ON a.activity_id = t.activity_id\n" +
				"WHERE t.transaction_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id";
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