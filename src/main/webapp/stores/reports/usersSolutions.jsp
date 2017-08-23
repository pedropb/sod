<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "reports_users_solutions", response, out)){
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

if (groupBy.equals("Usuário")) {
	sql = 	"SELECT\n" +
			"	u.user_id AS id,\n" +
			"	u.name AS name,\n" +
			"	COUNT(us.*) AS quantity\n" + 
			"FROM\n" +
			"	users u\n" +
			"	LEFT JOIN users_solutions us ON us.user_id = u.user_id\n" +
			"GROUP BY u.user_id, u.name ORDER BY u.name";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT us.*) AS quantity\n" + 
				"FROM\n" +
				"	users_solutions us\n" +
				"	RIGHT JOIN users u ON u.user_id = us.user_id\n" +
				"WHERE\n" +
				"	u.user_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	u.user_id AS reference_id,\n" +
				"	u.name AS reference,\n" +
				"	c.conflict_id AS conflict_id,\n" +
				"	c.name AS conflict,\n" +
				"	a1.activity_id AS activity1_id,\n" +
				"	a1.name AS activity1,\n" +
				"	a2.activity_id AS activity2_id,\n" +
				"	a2.name AS activity2\n" +
				"FROM\n" +
				"	users u\n" +
				"	INNER JOIN users_solutions us ON us.user_id = u.user_id\n" +
				"	INNER JOIN conflicts c ON us.conflict_id = c.conflict_id\n" +
				"	INNER JOIN activities a1 ON c.activity1 = a1.activity_id\n" +
				"	INNER JOIN activities a2 ON c.activity2 = a2.activity_id\n" +
				"WHERE\n" +
				"	us.user_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id, u.name";
}
else if (groupBy.equals("Transação")) {
	sql = 	"SELECT\n" +
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	COUNT(us.*) AS quantity\n" +
			"FROM\n" +
			"	transactions t\n" +
			" 	LEFT JOIN (" + usersTransactions + ") ut ON t.transaction_id = ut.transaction_id\n" +
			" 	LEFT JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
			" 	LEFT JOIN users_solutions us ON us.user_id = ut.user_id AND us.conflict_id = c.conflict_id\n" +
			"GROUP BY t.transaction_id, t.name\n" +
			"ORDER BY t.name";
			
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT us.*) AS quantity\n" +
				"FROM\n" +
				"	transactions t\n" +
				" 	LEFT JOIN (" + usersTransactions + ") ut ON t.transaction_id = ut.transaction_id\n" +
				" 	LEFT JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
				" 	LEFT JOIN users_solutions us ON us.user_id = ut.user_id AND us.conflict_id = c.conflict_id\n" +
				"WHERE\n" +
				"	t.transaction_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	u.user_id AS reference_id,\n" +
				"	u.name AS reference,\n" +
				"	c.conflict_id AS conflict_id,\n" +
				"	c.name AS conflict,\n" +
				"	a1.activity_id AS activity1_id,\n" +
				"	a1.name AS activity1,\n" +
				"	a2.activity_id AS activity2_id,\n" +
				"	a2.name AS activity2\n" +
				"FROM\n" +
				"	transactions t\n" +
				" 	INNER JOIN (" + usersTransactions + ") ut ON t.transaction_id = ut.transaction_id\n" +
				" 	INNER JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
				"	INNER JOIN activities a1 ON c.activity1 = a1.activity_id\n" +
				"	INNER JOIN activities a2 ON c.activity2 = a2.activity_id\n" +
				" 	INNER JOIN users_solutions us ON us.user_id = ut.user_id AND us.conflict_id = c.conflict_id\n" +
				"	INNER JOIN users u ON us.user_id = u.user_id\n" +
				"WHERE\n" +
				"	ut.transaction_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id, u.name";
}
else if (groupBy.equals("Atividade")) {
	String usersActivities = "SELECT\n" +
							"	user_id,\n" +
							"	activity_id\n" +
							"FROM\n" +
							"	users_activities\n" +
							"UNION\n" +
							"SELECT\n" +
							"	ug.user_id,\n" +
							"	ga.activity_id\n" +
							"FROM\n" +
							"	users_groups ug\n" +
							"	INNER JOIN groups_activities ga ON ug.group_id = ga.group_id";
	
	sql = 	"SELECT\n" +
			"	a.activity_id AS id,\n" +
			"	a.name,\n" +
			"	COUNT(DISTINCT us.*) AS quantity\n" +
			"FROM\n" +
			"	activities a \n "+ 
			"	LEFT JOIN (" + usersActivities + ") ua ON a.activity_id = ua.activity_id\n" +
			" 	LEFT JOIN conflicts c ON c.activity1 = a.activity_id OR c.activity2 = a.activity_id\n" +
			"	LEFT JOIN users_solutions us ON us.user_id = ua.user_id AND us.conflict_id = c.conflict_id\n" +
			"GROUP BY a.activity_id, a.name\n" +
			"ORDER BY a.activity_id";
			
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT us.*) AS quantity\n" +
				"FROM\n" +
				"	activities a \n "+ 
				"	LEFT JOIN (" + usersActivities + ") ua ON a.activity_id = ua.activity_id\n" +
				" 	LEFT JOIN conflicts c ON c.activity1 = a.activity_id OR c.activity2 = a.activity_id\n" +
				"	LEFT JOIN users_solutions us ON us.user_id = ua.user_id AND us.conflict_id = c.conflict_id\n" +
				"WHERE\n" +
				"	ua.activity_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	u.user_id AS reference_id,\n" +
				"	u.name AS reference,\n" +
				"	c.conflict_id AS conflict_id,\n" +
				"	c.name AS conflict,\n" +
				"	a1.activity_id AS activity1_id,\n" +
				"	a1.name AS activity1,\n" +
				"	a2.activity_id AS activity2_id,\n" +
				"	a2.name AS activity2\n" +
				"FROM\n" +
				"	activities a \n "+ 
				"	INNER JOIN (" + usersActivities + ") ua ON a.activity_id = ua.activity_id\n" +
				" 	INNER JOIN conflicts c ON c.activity1 = a.activity_id OR c.activity2 = a.activity_id\n" +
				"	INNER JOIN activities a1 ON c.activity1 = a1.activity_id\n" +
				"	INNER JOIN activities a2 ON c.activity2 = a2.activity_id\n" +
				"	INNER JOIN users_solutions us ON us.user_id = ua.user_id AND us.conflict_id = c.conflict_id\n" +
				"	INNER JOIN users u ON us.user_id = u.user_id\n" +
				"WHERE\n" +
				"	a.activity_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id, u.name";
}
else if (groupBy.equals("Módulo")) {
	sql = 	"SELECT\n" +
			"	m.module_id AS id,\n" +
			"	m.name AS name,\n" +
			"	COUNT(DISTINCT us.*) AS quantity\n" +
			"FROM\n" +
			"	modules m \n "+ 
			"	LEFT JOIN modules_transactions mt ON m.module_id = mt.module_id\n" +
			" 	LEFT JOIN (" + usersTransactions + ") ut ON mt.transaction_id = ut.transaction_id\n" +
			"	LEFT JOIN transactions t ON t.transaction_id = mt.transaction_id\n" +
			" 	LEFT JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
			" 	LEFT JOIN users_solutions us ON us.user_id = ut.user_id AND us.conflict_id = c.conflict_id\n" +
			"GROUP BY m.module_id, m.name\n" +
			"ORDER BY m.module_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT us.*) AS quantity\n" +
				"FROM\n" +
				"	modules_transactions mt\n" +
				"	INNER JOIN transactions t ON mt.transaction_id = t.transaction_id\n" +
				"	INNER JOIN (" + usersTransactions + ") ut ON ut.transaction_id = t.transaction_id\n" +
				" 	INNER JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
				" 	INNER JOIN users_solutions us ON us.user_id = ut.user_id AND us.conflict_id = c.conflict_id\n" +
				"WHERE\n" +
				"	mt.module_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT DISTINCT\n" +
				"	u.user_id AS reference_id,\n" +
				"	u.name AS reference,\n" +
				"	c.conflict_id AS conflict_id,\n" +
				"	c.name AS conflict,\n" +
				"	a1.activity_id AS activity1_id,\n" +
				"	a1.name AS activity1,\n" +
				"	a2.activity_id AS activity2_id,\n" +
				"	a2.name AS activity2\n" +
				"FROM\n" +
				"	modules m\n" +
				"	INNER JOIN modules_transactions mt ON m.module_id = mt.module_id\n" +
				"	INNER JOIN transactions t ON t.transaction_id = mt.transaction_id\n" +
				" 	INNER JOIN (" + usersTransactions + ") ut ON t.transaction_id = ut.transaction_id\n" +
				" 	INNER JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
				"	INNER JOIN activities a1 ON c.activity1 = a1.activity_id\n" +
				"	INNER JOIN activities a2 ON c.activity2 = a2.activity_id\n" +
				" 	INNER JOIN users_solutions us ON us.user_id = ut.user_id AND us.conflict_id = c.conflict_id\n" +
				"	INNER JOIN users u ON us.user_id = u.user_id\n" +
				"WHERE\n" +
				"	m.module_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id, u.name";
}
else if (groupBy.equals("Conflito")) {
	sql = 	"SELECT\n" +
			"	c.conflict_id AS id,\n" +
			"	c.name AS name,\n" +
			"	COUNT(DISTINCT us.*) AS quantity\n" + 
			"FROM\n" +
			"	conflicts c\n" +
			"	LEFT JOIN users_solutions us ON us.conflict_id = c.conflict_id\n" +
			"GROUP BY c.conflict_id, c.name\n" +
			"ORDER BY c.conflict_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT us.*) AS quantity\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"	LEFT JOIN users_solutions us ON us.conflict_id = c.conflict_id\n" +
				"WHERE\n" +
				"	c.conflict_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT DISTINCT\n" +
				"	u.user_id AS reference_id,\n" +
				"	u.name AS reference,\n" +
				"	c.conflict_id AS conflict_id,\n" +
				"	c.name AS conflict,\n" +
				"	a1.activity_id AS activity1_id,\n" +
				"	a1.name AS activity1,\n" +
				"	a2.activity_id AS activity2_id,\n" +
				"	a2.name AS activity2\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"	INNER JOIN activities a1 ON c.activity1 = a1.activity_id\n" +
				"	INNER JOIN activities a2 ON c.activity2 = a2.activity_id\n" +
				" 	INNER JOIN users_solutions us ON us.conflict_id = c.conflict_id\n" +
				"	INNER JOIN users u ON us.user_id = u.user_id\n" +
				"WHERE\n" +
				"	c.conflict_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id, u.name";
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