<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "reports_groups", response, out)){
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
			"	COUNT(DISTINCT ug.group_id) AS quantity\n" + 
			"FROM\n" +
			"	users_groups ug\n" +
			"	RIGHT JOIN users u ON u.user_id = ug.user_id\n" +
			"GROUP BY u.user_id, u.name ORDER BY u.name";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ug.group_id) AS quantity\n" + 
				"FROM\n" +
				"	users_groups ug\n" +
				"WHERE\n" +
				"	ug.user_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	g.group_id AS id,\n" +
				"	g.name AS name\n" +
				"FROM\n" +
				"	groups g\n" +
				"	INNER JOIN users_groups ug ON ug.group_id = g.group_id\n" +
				"WHERE\n" +
				"	ug.user_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY g.group_id, g.name";
}
else if (groupBy.equals("Transação")) {
	sql = 	"SELECT\n" +
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	(SELECT COUNT(*) FROM groups_transactions WHERE transaction_id = t.transaction_id) AS quantity\n" +
			"FROM\n" +
			"	transactions t\n" +
			"ORDER BY t.name";
			
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT group_id) AS quantity\n" +
				"FROM\n" +
				"	groups_transactions gt\n" +
				"WHERE\n" +
				"	gt.transaction_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	g.group_id AS id,\n" +
				"	g.name AS name\n" +
				"FROM\n" +
				"	groups g\n" +
				"	INNER JOIN groups_transactions gt ON gt.group_id = g.group_id\n" +
				"WHERE\n" +
				"	gt.transaction_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY g.group_id, g.name";
}
else if (groupBy.equals("Atividade")) {
	sql = 	"SELECT\n" +
			"	a.activity_id AS id,\n" +
			"	a.name,\n" +
			"	COUNT(DISTINCT ga.group_id) AS quantity\n" +
			"FROM\n" +
			"	activities a \n "+ 
			"	LEFT JOIN groups_activities ga ON a.activity_id = ga.activity_id\n" +
			"GROUP BY a.activity_id, a.name\n" +
			"ORDER BY a.activity_id";
			
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ga.group_id) AS quantity\n" +
				"FROM\n" +
				"	groups_activities ga\n" +
				"WHERE\n" +
				"	ga.activity_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	g.group_id AS id,\n" +
				"	g.name AS name\n" +
				"FROM\n" +
				"	groups g\n" +
				"	INNER JOIN groups_activities ga ON ga.group_id = g.group_id\n" +
				"ORDER BY g.group_id, g.name";
}
else if (groupBy.equals("Módulo")) {
	sql = 	"SELECT\n" +
			"	m.module_id AS id,\n" +
			"	m.name,\n" +
			"	COUNT(DISTINCT ug.group_id) AS quantity\n" +
			"FROM\n" +
			"	modules m \n "+ 
			"	LEFT JOIN modules_transactions mt ON m.module_id = mt.module_id\n" +
			"	LEFT JOIN transactions t ON mt.transaction_id = t.transaction_id\n" +
			"	LEFT JOIN groups_transactions ug ON ug.transaction_id = t.transaction_id\n" +
			"GROUP BY m.module_id, m.name\n" +
			"ORDER BY m.module_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ug.group_id) AS quantity\n" +
				"FROM\n" +
				"	modules_transactions mt\n" +
				"	INNER JOIN transactions t ON mt.transaction_id = t.transaction_id\n" +
				"	INNER JOIN groups_transactions ug ON ug.transaction_id = t.transaction_id\n" +
				"WHERE\n" +
				"	mt.module_id NOT IN (%TOP_ENTRIES%)";
	
	String detailSqlAux = 	"SELECT DISTINCT\n" +
							"	gt.group_id\n" +
							"FROM\n" +
							"	groups_transactions gt\n" +
							"	INNER JOIN transactions t ON t.transaction_id = gt.transaction_id\n" +
							"	INNER JOIN modules_transactions mt ON t.transaction_id = mt.transaction_id\n" +
							"WHERE mt.module_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n";
	
	detailSql = "SELECT\n" +
				"	g.group_id AS id,\n" +
				"	g.name AS name\n" +
				"FROM\n" +
				"	groups g\n" +
				"	INNER JOIN (" + detailSqlAux + ") gt ON gt.group_id = g.group_id\n" +
				"ORDER BY g.group_id, g.name";
}
else if (groupBy.equals("Conflito")) {
	sql = 	"SELECT\n" +
			"	c.conflict_id AS id,\n" +
			"	c.name AS name,\n" +
			"	COUNT(DISTINCT ga.group_id) AS quantity\n" + 
			"FROM\n" +
			"	conflicts c\n" +
			"	LEFT JOIN groups_activities ga ON ga.activity_id = c.activity1\n" +
			"	LEFT JOIN groups_activities ga2 ON ga2.activity_id = c.activity2\n" +
			"WHERE\n" +
			"	ga.group_id = ga2.group_id\n" +
			"GROUP BY c.conflict_id, c.name\n" +
			"ORDER BY c.conflict_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT ga.group_id) AS quantity\n" + 
				"FROM\n" +
				"	conflicts c\n" +
				"	LEFT JOIN groups_activities ga ON ga.activity_id = c.activity1\n" +
				"	LEFT JOIN groups_activities ga2 ON ga2.activity_id = c.activity2\n" +
				"WHERE\n" +
				"	ga.group_id = ga2.group_id AND\n" +
				"	c.conflict_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	g.group_id AS id,\n" +
				"	g.name AS name\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"	LEFT JOIN groups_activities ga ON ga.activity_id = c.activity1\n" +
				"	LEFT JOIN groups_activities ga2 ON ga2.activity_id = c.activity2\n" +
				"	INNER JOIn groups g ON ga.group_id = g.group_id\n" +
				"WHERE\n" +
				"	ga.group_id = ga2.group_id\n" +
				"	AND c.conflict_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY g.group_id, g.name";
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