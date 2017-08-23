<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "reports_users", response, out)){
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
String usersTransactions = 	"SELECT\n" +
							"	ut.user_id,\n" +
							"	ut.transaction_id\n" +
							"FROM\n" +
							"	users_transactions ut\n" +
							"UNION\n" +
							"SELECT\n" +
							"	ug.user_id,\n" +
							"	gt.transaction_id\n" +
							"FROM\n" +
							"	groups_transactions gt\n" +
							"	INNER JOIN users_groups ug ON gt.group_id = ug.group_id";

if (groupBy.equals("Grupo")) {
	sql = 	"SELECT\n" +
			"	g.group_id AS id,\n" +
			"	g.name AS name,\n" +
			"	COUNT(ug.user_id) AS quantity\n" + 
			"FROM\n" +
			"	users_groups ug\n" +
			"	RIGHT JOIN groups g ON g.group_id = ug.group_id\n" +
			"GROUP BY g.group_id, g.name ORDER BY g.name";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ug.user_id) AS quantity\n" + 
				"FROM\n" +
				"	users_groups ug\n" +
				"	RIGHT JOIN groups g ON g.group_id = ug.group_id\n" +
				"WHERE\n" +
				"	g.group_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	u.user_id AS id,\n" +
				"	u.name AS name\n" +
				"FROM\n" +
				"	users u\n" +
				"	INNER JOIN users_groups ug ON ug.user_id = u.user_id\n" +
				"WHERE\n" +
				"	ug.group_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY u.name";
}
else if (groupBy.equals("Transação")) {
	sql = 	"SELECT\n" +
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	(SELECT COUNT(ut.user_id) FROM (" + usersTransactions + ") ut WHERE ut.transaction_id = t.transaction_id) AS quantity\n" +
			"FROM\n" +
			"	transactions t\n" +
			"ORDER BY t.name";
			
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ut.user_id) AS quantity\n" +
				"FROM\n" +
				"	(" + usersTransactions + ") ut\n" +
				"WHERE\n" +
				"	ut.transaction_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	u.user_id AS id,\n" +
				"	u.name AS name\n" +
				"FROM\n" +
				"	users u\n" +
				"	INNER JOIN (" + usersTransactions + ") ut ON ut.user_id = u.user_id\n" +
				"WHERE\n" +
				"	ut.transaction_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY u.name";
}
else if (groupBy.equals("Atividade")) {
	sql = 	"SELECT\n" +
			"	a.activity_id AS id,\n" +
			"	a.name,\n" +
			"	COUNT(DISTINCT ua.user_id) AS quantity\n" +
			"FROM\n" +
			"	activities a \n "+ 
			"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON a.activity_id = ua.activity_id\n" +
			"GROUP BY a.activity_id, a.name\n" +
			"ORDER BY a.activity_id";
			
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ua.user_id) AS quantity\n" +
				"FROM\n" +
				"	(SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua\n" +
				"WHERE\n" +
				"	ua.activity_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	u.user_id AS id,\n" +
				"	u.name AS name\n" +
				"FROM\n" +
				"	users u\n" +
				"	INNER JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON ua.user_id = u.user_id\n" +
				"WHERE\n" +
				"	ua.activity_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY u.name";
}
else if (groupBy.equals("Módulo")) {
	sql = 	"SELECT\n" +
			"	m.module_id AS id,\n" +
			"	m.name AS name,\n" +
			"	COUNT(DISTINCT ut.user_id) AS quantity\n" +
			"FROM\n" +
			"	modules m \n "+ 
			"	LEFT JOIN modules_transactions mt ON m.module_id = mt.module_id\n" +
			"	LEFT JOIN transactions t ON mt.transaction_id = t.transaction_id\n" +
			"	LEFT JOIN (" + usersTransactions + ") ut ON ut.transaction_id = t.transaction_id\n" +
			"GROUP BY m.module_id, m.name\n" +
			"ORDER BY m.module_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ut.user_id) AS quantity\n" +
				"FROM\n" +
				"	modules_transactions mt\n" +
				"	INNER JOIN transactions t ON mt.transaction_id = t.transaction_id\n" +
				"	INNER JOIN (" + usersTransactions + ") ut ON ut.transaction_id = t.transaction_id\n" +
				"WHERE\n" +
				"	mt.module_id NOT IN (%TOP_ENTRIES%)";
	
	String detailSqlAux = 	"SELECT DISTINCT\n" +
							"	ut.user_id\n" +
							"FROM\n" +
							"	(" + usersTransactions + ") ut\n" +
							"	INNER JOIN transactions t ON t.transaction_id = ut.transaction_id\n" +
							"	INNER JOIN modules_transactions mt ON t.transaction_id = mt.transaction_id\n" +
							"WHERE mt.module_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n";
	
	detailSql = "SELECT\n" +
				"	u.user_id AS id,\n" +
				"	u.name AS name\n" +
				"FROM\n" +
				"	users u\n" +
				"	INNER JOIN (" + detailSqlAux + ") ut ON ut.user_id = u.user_id\n" +
				"ORDER BY u.name";
}
else if (groupBy.equals("Conflito")) {
	sql = 	"SELECT\n" +
			"	c.conflict_id AS id,\n" +
			"	c.name AS name,\n" +
			"	COUNT(DISTINCT ua.user_id) AS quantity\n" + 
			"FROM\n" +
			"	conflicts c\n" +
			"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON ua.activity_id = c.activity1\n" +
			"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua2 ON ua2.activity_id = c.activity2\n" +
			"WHERE\n" +
			"	ua.user_id = ua2.user_id\n" +
			"GROUP BY c.conflict_id, c.name\n" +
			"ORDER BY c.conflict_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ua.user_id) AS quantity\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON ua.activity_id = c.activity1\n" +
				"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua2 ON ua2.activity_id = c.activity2\n" +
				"WHERE\n" +
				"	ua.user_id = ua2.user_id\n" +
				"	AND c.conflict_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	u.user_id AS id,\n" +
				"	u.name\n" +
				"FROM\n" +
				"	users u\n" +
				"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON ua.user_id = u.user_id\n" +
				"	LEFT JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua2 ON ua2.user_id = u.user_id\n" +
				"	LEFT JOIN conflicts c ON c.activity1 = ua.activity_id AND c.activity2 = ua2.activity_id\n" +
				"WHERE\n" +
				"	c.conflict_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY u.name";
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