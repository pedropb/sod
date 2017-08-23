<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "reports_modules", response, out)){
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
								
	
	sql = 	"SELECT\n" +
			"	u.user_id AS id,\n" +
			"	u.name AS name,\n" +
			"	(SELECT COUNT(DISTINCT mt.module_id) FROM ("+ usersTransactions +") ut INNER JOIN modules_transactions mt ON mt.transaction_id = ut.transaction_id WHERE ut.user_id = u.user_id) AS quantity\n" + 
			"FROM\n" +
			"	users u\n" +
			"ORDER BY u.name";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT mt.module_id) AS quantity\n" + 
				"FROM\n" +
				"	("+ usersTransactions +") ut\n" +
				"	INNER JOIN modules_transactions mt ON mt.transaction_id = ut.transaction_id\n" +
				"WHERE\n" +
				"	ut.user_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	m.module_id AS id,\n" +
				"	m.name AS name\n" +
				"FROM\n" +
				"	modules m\n" +
				"	INNER JOIN modules_transactions mt ON mt.module_id = m.module_id\n" +
				"	INNER JOIN ("+ usersTransactions +") ut ON ut.transaction_id = mt.transaction_id\n" +
				"WHERE\n" +
				"	ut.user_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY m.module_id";
}
else if (groupBy.equals("Grupo")) {
	sql = 	"SELECT\n" +
			"	g.group_id AS id,\n" +
			"	g.name AS name,\n" +
			"	(SELECT COUNT(DISTINCT mt.module_id) FROM groups_transactions gt INNER JOIN modules_transactions mt ON mt.transaction_id = gt.transaction_id WHERE gt.group_id = g.group_id) AS quantity\n" + 
			"FROM\n" +
			"	groups g\n" +
			"ORDER BY g.name";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT mt.module_id) AS quantity\n" + 
				"FROM\n" +
				"	groups_transactions gt\n" +
				"	INNER JOIN modules_transactions mt ON mt.transaction_id = gt.transaction_id\n" +
				"WHERE\n" +
				"	gt.group_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	m.module_id AS id,\n" +
				"	m.name AS name\n" +
				"FROM\n" +
				"	modules m\n" +
				"	INNER JOIN modules_transactions mt ON mt.module_id = m.module_id\n" +
				"	INNER JOIN groups_transactions gt ON gt.transaction_id = mt.transaction_id\n" +
				"WHERE\n" +
				"	gt.group_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY m.module_id";
}
else if (groupBy.equals("Atividade")) {
	String sqlActivities = 	"SELECT DISTINCT\n" +
							"	t.activity_id,\n" +
							"	mt.module_id\n" +
							"FROM\n" +
							"	modules_transactions mt\n" +
							"	INNER JOIN transactions t ON t.transaction_id = mt.transaction_id\n";

	sql = 	"SELECT\n" +
			"	a.activity_id AS id,\n" +
			"	a.name,\n" +
			"	COUNT(t.transaction_id) AS quantity\n" +
			"FROM\n" +
			"	activities a \n "+ 
			"	LEFT JOIN (" + sqlActivities +") t ON a.activity_id = t.activity_id\n" +
			"GROUP BY a.activity_id, a.name\n" +
			"ORDER BY a.activity_id";
	
	otherSql = 	"SELECT\n" +
				"	(SELECT COUNT(*) FROM modules_transactions WHERE transaction_id = t.transaction_id) AS quantity\n" +
				"FROM\n" +
				"	transactions t\n" +
				"WHERE\n" +
				"	t.activity_id NOT IN (%TOP_ENTRIES%)";
	
	String detailSqlAux = 	"SELECT DISTINCT\n" +
							"	mt.module_id\n" +
							"FROM\n" +
							"	modules_transactions mt\n" +
							"	INNER JOIN transactions t ON t.transaction_id = mt.transaction_id\n" +
							"WHERE t.activity_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n";
	
	detailSql = "SELECT\n" +
				"	m.module_id AS id,\n" +
				"	m.name AS name\n" +
				"FROM\n" +
				"	modules m\n" +
				"	INNER JOIN (" + detailSqlAux + ") mt ON mt.module_id = m.module_id\n" +
				"ORDER BY m.module_id";
}
else if (groupBy.equals("Transação")) {
	sql = 	"SELECT\n" +
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	(SELECT COUNT(*) FROM modules_transactions WHERE transaction_id = t.transaction_id) AS quantity\n" +
			"FROM\n" +
			"	transactions t\n" +
			"ORDER BY t.name";
			
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT mt.module_id) AS quantity\n" +
				"FROM\n" +
				"	modules_transactions mt t\n" +
				"WHERE\n" +
				"	mt.transaction_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	m.module_id AS id,\n" +
				"	m.name AS name\n" +
				"FROM\n" +
				"	modules m\n" +
				"	INNER JOIN modules_transactions mt ON mt.module_id = m.module_id\n" +
				"WHERE\n" +
				"	mt.transaction_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY m.module_id";
}
else if (groupBy.equals("Conflito")) {
	sql = 	"SELECT\n" +
			"	c.conflict_id AS id,\n" +
			"	c.name AS name,\n" +
			"	COUNT(m.module_id) AS quantity\n" + 
			"FROM\n" +
			"	modules m\n";
	
	String sqlActivities = 	"SELECT DISTINCT\n" +
							"	t.activity_id,\n" +
							"	mt.module_id\n" +
							"FROM\n" +
							"	modules_transactions mt\n" +
							"	INNER JOIN transactions t ON t.transaction_id = mt.transaction_id\n";
	
	sql += 	"	RIGHT JOIN (" + sqlActivities + ") a1 ON a1.module_id = m.module_id\n" +
			"	RIGHT JOIN (" + sqlActivities + ") a2 ON a2.module_id = m.module_id\n" +
			"	RIGHT JOIN conflicts c ON c.activity1 = a1.activity_id AND c.activity2 = a2.activity_id";
	
	sql += " GROUP BY c.conflict_id, c.name ORDER BY c.conflict_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT m.module_id) AS quantity\n" +
				"FROM\n" +
				"	modules m\n" +
				"	RIGHT JOIN (" + sqlActivities + ") a1 ON a1.module_id = m.module_id\n" +
				"	RIGHT JOIN (" + sqlActivities + ") a2 ON a2.module_id = m.module_id\n" +
				"	INNER JOIN conflicts c ON c.activity1 = a1.activity_id AND c.activity2 = a2.activity_id\n" + 
				"WHERE\n" +
				"	c.conflict_id NOT IN (%TOP_ENTRIES%)";
	
	String detailSqlAux1 = 	"SELECT DISTINCT\n" +
							"	mt.module_id\n" +
							"FROM\n" +
							"	modules_transactions mt \n" +
							"	INNER JOIN transactions t ON t.transaction_id = mt.transaction_id\n" +
							"WHERE\n" +
							"	t.activity_id IN (	SELECT\n" +
							"							activity1\n" +
							"						FROM\n" +
							"							conflicts \n" +
							"						WHERE\n" +
							"							conflict_id = '"+ StringEscapeUtils.escapeSql(detail) + "')";
	
	String detailSqlAux2 = 	"SELECT DISTINCT\n" +
							"	mt.module_id\n" +
							"FROM\n" +
							"	modules_transactions mt \n" +
							"	INNER JOIN transactions t ON t.transaction_id = mt.transaction_id\n" +
							"WHERE\n" +
							"	t.activity_id IN (	SELECT\n" +
							"							activity2\n" +
							"						FROM\n" +
							"							conflicts \n" +
							"						WHERE\n" +
							"							conflict_id = '"+ StringEscapeUtils.escapeSql(detail) + "')";;
	
	
	detailSql = "SELECT\n" +
				"	m.module_id AS id,\n" +
				"	m.name\n" +
				"FROM\n" +
				"	modules m\n" +
				"	INNER JOIN (" + detailSqlAux1 + ") c1 ON m.module_id = c1.module_id\n" +
				"	INNER JOIN (" + detailSqlAux2 + ") c2 ON c1.module_id = c2.module_id\n" +
				"ORDER BY m.module_id";
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