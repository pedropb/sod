<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "reports_groups_solutions", response, out)){
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

if (groupBy.equals("Grupo")) {
	sql = 	"SELECT\n" +
			"	g.group_id AS id,\n" +
			"	g.name AS name,\n" +
			"	COUNT(gs.*) AS quantity\n" + 
			"FROM\n" +
			"	groups g\n" +
			"	LEFT JOIN groups_solutions gs ON gs.group_id = g.group_id\n" +
			"GROUP BY g.group_id, g.name ORDER BY g.name";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT gs.*) AS quantity\n" + 
				"FROM\n" +
				"	groups_solutions gs\n" +
				"	RIGHT JOIN groups g ON g.group_id = gs.group_id\n" +
				"WHERE\n" +
				"	g.group_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	g.group_id AS reference_id,\n" +
				"	g.name AS reference,\n" +
				"	c.conflict_id AS conflict_id,\n" +
				"	c.name AS conflict,\n" +
				"	a1.activity_id AS activity1_id,\n" +
				"	a1.name AS activity1,\n" +
				"	a2.activity_id AS activity2_id,\n" +
				"	a2.name AS activity2\n" +
				"FROM\n" +
				"	groups g\n" +
				"	INNER JOIN groups_solutions gs ON gs.group_id = g.group_id\n" +
				"	INNER JOIN conflicts c ON gs.conflict_id = c.conflict_id\n" +
				"	INNER JOIN activities a1 ON c.activity1 = a1.activity_id\n" +
				"	INNER JOIN activities a2 ON c.activity2 = a2.activity_id\n" +
				"WHERE\n" +
				"	gs.group_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id, g.name";
}
else if (groupBy.equals("Transação")) {
	sql = 	"SELECT\n" +
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	COUNT(gs.*) AS quantity\n" +
			"FROM\n" +
			"	transactions t\n" +
			" 	LEFT JOIN groups_transactions gt ON t.transaction_id = gt.transaction_id\n" +
			" 	LEFT JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
			" 	LEFT JOIN groups_solutions gs ON gs.group_id = gt.group_id AND gs.conflict_id = c.conflict_id\n" +
			"GROUP BY t.transaction_id, t.name\n" +
			"ORDER BY t.name";
			
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT gs.*) AS quantity\n" +
				"FROM\n" +
				"	transactions t\n" +
				" 	LEFT JOIN groups_transactions gt ON t.transaction_id = gt.transaction_id\n" +
				" 	LEFT JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
				" 	LEFT JOIN groups_solutions gs ON gs.group_id = gt.group_id AND gs.conflict_id = c.conflict_id\n" +
				"WHERE\n" +
				"	t.transaction_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	g.group_id AS reference_id,\n" +
				"	g.name AS reference,\n" +
				"	c.conflict_id AS conflict_id,\n" +
				"	c.name AS conflict,\n" +
				"	a1.activity_id AS activity1_id,\n" +
				"	a1.name AS activity1,\n" +
				"	a2.activity_id AS activity2_id,\n" +
				"	a2.name AS activity2\n" +
				"FROM\n" +
				"	transactions t\n" +
				" 	INNER JOIN groups_transactions gt ON t.transaction_id = gt.transaction_id\n" +
				" 	INNER JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
				"	INNER JOIN activities a1 ON c.activity1 = a1.activity_id\n" +
				"	INNER JOIN activities a2 ON c.activity2 = a2.activity_id\n" +
				" 	INNER JOIN groups_solutions gs ON gs.group_id = gt.group_id AND gs.conflict_id = c.conflict_id\n" +
				"	INNER JOIN groups g ON gs.group_id = g.group_id\n" +
				"WHERE\n" +
				"	gt.transaction_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id, g.name";
}
else if (groupBy.equals("Atividade")) {
	sql = 	"SELECT\n" +
			"	a.activity_id AS id,\n" +
			"	a.name,\n" +
			"	COUNT(DISTINCT gs.*) AS quantity\n" +
			"FROM\n" +
			"	activities a \n "+ 
			"	LEFT JOIN groups_activities ga ON a.activity_id = ga.activity_id\n" +
			" 	LEFT JOIN conflicts c ON c.activity1 = a.activity_id OR c.activity2 = a.activity_id\n" +
			"	LEFT JOIN groups_solutions gs ON gs.group_id = ga.group_id AND gs.conflict_id = c.conflict_id\n" +
			"GROUP BY a.activity_id, a.name\n" +
			"ORDER BY a.activity_id";
			
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT gs.*) AS quantity\n" +
				"FROM\n" +
				"	activities a \n "+ 
				"	LEFT JOIN groups_activities ga ON a.activity_id = ga.activity_id\n" +
				" 	LEFT JOIN conflicts c ON c.activity1 = a.activity_id OR c.activity2 = a.activity_id\n" +
				"	LEFT JOIN groups_solutions gs ON gs.group_id = ga.group_id AND gs.conflict_id = c.conflict_id\n" +
				"WHERE\n" +
				"	ua.activity_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT\n" +
				"	g.group_id AS reference_id,\n" +
				"	g.name AS reference,\n" +
				"	c.conflict_id AS conflict_id,\n" +
				"	c.name AS conflict,\n" +
				"	a1.activity_id AS activity1_id,\n" +
				"	a1.name AS activity1,\n" +
				"	a2.activity_id AS activity2_id,\n" +
				"	a2.name AS activity2\n" +
				"FROM\n" +
				"	activities a \n "+ 
				"	INNER JOIN groups_activities ga ON a.activity_id = ga.activity_id\n" +
				" 	INNER JOIN conflicts c ON c.activity1 = a.activity_id OR c.activity2 = a.activity_id\n" +
				"	INNER JOIN activities a1 ON c.activity1 = a1.activity_id\n" +
				"	INNER JOIN activities a2 ON c.activity2 = a2.activity_id\n" +
				"	INNER JOIN groups_solutions gs ON gs.group_id = ga.group_id AND gs.conflict_id = c.conflict_id\n" +
				"	INNER JOIN groups g ON gs.group_id = g.group_id\n" +
				"WHERE\n" +
				"	a.activity_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id, g.name";
}
else if (groupBy.equals("Módulo")) {
	sql = 	"SELECT\n" +
			"	m.module_id AS id,\n" +
			"	m.name AS name,\n" +
			"	COUNT(DISTINCT gs.*) AS quantity\n" +
			"FROM\n" +
			"	modules m \n "+ 
			"	LEFT JOIN modules_transactions mt ON m.module_id = mt.module_id\n" +
			" 	LEFT JOIN groups_transactions gt ON mt.transaction_id = gt.transaction_id\n" +
			"	LEFT JOIN transactions t ON t.transaction_id = mt.transaction_id\n" +
			" 	LEFT JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
			" 	LEFT JOIN groups_solutions gs ON gs.group_id = gt.group_id AND gs.conflict_id = c.conflict_id\n" +
			"GROUP BY m.module_id, m.name\n" +
			"ORDER BY m.module_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT gs.*) AS quantity\n" +
				"FROM\n" +
				"	modules_transactions mt\n" +
				"	INNER JOIN transactions t ON mt.transaction_id = t.transaction_id\n" +
				"	INNER JOIN groups_transactions gt ON gt.transaction_id = t.transaction_id\n" +
				" 	INNER JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
				" 	INNER JOIN groups_solutions gs ON gs.group_id = gt.group_id AND gs.conflict_id = c.conflict_id\n" +
				"WHERE\n" +
				"	mt.module_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT DISTINCT\n" +
				"	g.group_id AS reference_id,\n" +
				"	g.name AS reference,\n" +
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
				" 	INNER JOIN groups_transactions gt ON t.transaction_id = gt.transaction_id\n" +
				" 	INNER JOIN conflicts c ON c.activity1 = t.activity_id OR c.activity2 = t.activity_id\n" +
				"	INNER JOIN activities a1 ON c.activity1 = a1.activity_id\n" +
				"	INNER JOIN activities a2 ON c.activity2 = a2.activity_id\n" +
				" 	INNER JOIN groups_solutions gs ON gs.group_id = gt.group_id AND gs.conflict_id = c.conflict_id\n" +
				"	INNER JOIN groups g ON gs.group_id = g.group_id\n" +
				"WHERE\n" +
				"	m.module_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id, g.name";
}
else if (groupBy.equals("Conflito")) {
	sql = 	"SELECT\n" +
			"	c.conflict_id AS id,\n" +
			"	c.name AS name,\n" +
			"	COUNT(DISTINCT gs.*) AS quantity\n" + 
			"FROM\n" +
			"	conflicts c\n" +
			"	LEFT JOIN groups_solutions gs ON gs.conflict_id = c.conflict_id\n" +
			"GROUP BY c.conflict_id, c.name\n" +
			"ORDER BY c.conflict_id";
	
	otherSql = 	"SELECT\n" +
				"	COUNT(DISTINCT gs.*) AS quantity\n" +
				"FROM\n" +
				"	conflicts c\n" +
				"	LEFT JOIN groups_solutions gs ON gs.conflict_id = c.conflict_id\n" +
				"WHERE\n" +
				"	c.conflict_id NOT IN (%TOP_ENTRIES%)";
	
	detailSql = "SELECT DISTINCT\n" +
				"	g.group_id AS reference_id,\n" +
				"	g.name AS reference,\n" +
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
				" 	INNER JOIN groups_solutions gs ON gs.conflict_id = c.conflict_id\n" +
				"	INNER JOIN groups g ON gs.group_id = g.group_id\n" +
				"WHERE\n" +
				"	c.conflict_id = '" + StringEscapeUtils.escapeSql(detail) + "'\n" +
				"ORDER BY c.conflict_id, g.name";
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