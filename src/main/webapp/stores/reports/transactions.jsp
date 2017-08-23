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
			"	(SELECT COUNT(ut.transaction_id) FROM (" + usersTransactions + ") ut WHERE ut.user_id = u.user_id) AS quantity\n" + 
			"FROM\n" +
			"	users u\n" +
			"ORDER BY u.name";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ut.transaction_id) AS quantity\n" + 
				"FROM\n" +
				"	(" + usersTransactions + ") ut\n" +
				"WHERE\n" +
				"	ut.user_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	t.transaction_id AS id,\n" +
				"	t.name AS name\n" +
				"FROM\n" +
				"	transactions t\n" +
				"	INNER JOIN (" + usersTransactions + ") ut ON ut.transaction_id = t.transaction_id\n" +
				"WHERE\n" +
				"	ut.user_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY t.name";
}
else if (groupBy.equals("Grupo")) {
	sql = 	"SELECT\n" +
			"	g.group_id AS id,\n" +
			"	g.name AS name,\n" +
			"	(SELECT COUNT(transaction_id) FROM groups_transactions WHERE group_id = g.group_id) AS quantity\n" + 
			"FROM\n" +
			"	groups g\n" +
			"ORDER BY g.name";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT gt.transaction_id) AS quantity\n" + 
				"FROM\n" +
				"	groups_transactions gt\n" +
				"WHERE\n" +
				"	gt.group_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	t.transaction_id AS id,\n" +
				"	t.name AS name\n" +
				"FROM\n" +
				"	transactions t\n" +
				"	INNER JOIN groups_transactions gt ON gt.transaction_id = t.transaction_id\n" +
				"WHERE\n" +
				"	gt.group_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY t.name";
}
else if (groupBy.equals("Atividade")) {
	sql = 	"SELECT\n" +
			"	a.activity_id AS id,\n" +
			"	a.name,\n" +
			"	COUNT(t.transaction_id) AS quantity\n" +
			"FROM\n" +
			"	activities a \n "+ 
			"	LEFT JOIN transactions t ON a.activity_id = t.activity_id\n" +
			"GROUP BY a.activity_id, a.name\n" +
			"ORDER BY a.activity_id";
			
	otherSql = 	"SELECT\n" +
				"	COUNT(*) AS quantity\n" +
				"FROM\n" +
				"	transactions t\n" +
				"WHERE\n" +
				"	t.activity_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	t.transaction_id AS id,\n" +
				"	t.name AS name\n" +
				"FROM\n" +
				"	transactions t\n" +
				"WHERE t.activity_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY t.name";
}
else if (groupBy.equals("Módulo")) {
	sql = 	"SELECT\n" +
			"	m.module_id AS id,\n" +
			"	m.name,\n" +
			"	COUNT(mt.transaction_id) AS quantity\n" +
			"FROM\n" +
			"	modules m \n "+ 
			"	LEFT JOIN modules_transactions mt ON m.module_id = mt.module_id\n" +
			"GROUP BY m.module_id, m.name\n" +
			"ORDER BY m.module_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(mt.transaction_id) AS quantity\n" +
				"FROM\n" +
				"	modules_transactions mt\n" +
				"WHERE\n" +
				"	mt.module_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	t.transaction_id AS id,\n" +
				"	t.name AS name\n" +
				"FROM\n" +
				"	transactions t\n" +
				"	INNER JOIN modules_transactions mt ON mt.transaction_id = t.transaction_id\n" +
				"WHERE\n" +
				"	mt.module_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY t.name";
}
else if (groupBy.equals("Conflito")) {
	sql = 	"SELECT\n" +
			"	c.conflict_id AS id,\n" +
			"	c.name AS name,\n" +
			"	(SELECT COUNT(*) FROM transactions WHERE activity_id = c.activity1 OR activity_id = c.activity2) AS quantity\n" + 
			"FROM\n" +
			"	conflicts c\n" +
			"ORDER BY c.conflict_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(*) AS quantity\n" +
				"FROM\n" +
				"	transactions t\n" +
				"WHERE\n" +
				"	t.activity_id NOT IN (SELECT c.activity1 FROM conflicts c WHERE c.conflict_id NOT IN (%TOP_ENTRIES%) \n"+
				"							UNION SELECT c.activity2 FROM conflicts c WHERE c.conflict_id NOT IN (%TOP_ENTRIES%))";
	
	detailSql = "SELECT\n" +
				"	t.transaction_id AS id,\n" +
				"	t.name AS name\n" +
				"FROM\n" +
				"	transactions t\n" +
				"WHERE\n" +
				"	t.activity_id IN (SELECT c.activity1 FROM conflicts c WHERE c.conflict_id = '" + StringEscapeUtils.escapeSql(detail) + "' \n"+
				"						UNION SELECT c.activity2 FROM conflicts c WHERE c.conflict_id = '" + StringEscapeUtils.escapeSql(detail) + "')\n" +
				"ORDER BY t.name";
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