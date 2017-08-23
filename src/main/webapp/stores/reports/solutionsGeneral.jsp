<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (request.getParameter("groupBy") == null) {
	Permissions.outputError(response, out);
	return;
}

String groupBy = request.getParameter("groupBy");

if (groupBy.equals("Usuário")) {
	if (!Permissions.canRead(session, "reports_users_solutions_general", response, out)) {
		return;
	}
	
	sql = 	"SELECT\n" +
			"	c.name AS conflict,\n" +
			"	a1.name AS activity1,\n" +
			"	a2.name AS activity2,\n" +
			"	u.user_id AS target_id,\n" +
			"	u.name AS name,\n" +
			"	us.reason AS description,\n" +
			"	us.reason_created AS created,\n" +
			"	gtu.login AS user\n" +
			"FROM\n" +
			"	conflicts c\n" +
			"	INNER JOIN activities a1 ON a1.activity_id = c.activity1\n" +
			"	INNER JOIN activities a2 ON a2.activity_id = c.activity2\n" +
			"	INNER JOIN users_solutions us ON us.conflict_id = c.conflict_id\n" +
			"	INNER JOIN users u ON us.user_id = u.user_id\n" +
			"	INNER JOIN gt_users gtu ON gtu.id = us.gt_user_id\n" +
			"ORDER BY created DESC, u.name, c.name";
	
	System.out.println(sql);
}
else {
	if (!Permissions.canRead(session, "reports_groups_solutions_general", response, out)) {
		return;
	}
	
	sql = 	"SELECT\n" +
			"	c.name AS conflict,\n" +
			"	a1.name AS activity1,\n" +
			"	a2.name AS activity2,\n" +
			"	g.group_id AS target_id,\n" +
			"	g.name AS name,\n" +
			"	gs.reason AS description,\n" +
			"	gs.reason_created AS created,\n" +
			"	gtu.login AS user\n" +
			"FROM\n" +
			"	conflicts c\n" +
			"	INNER JOIN activities a1 ON a1.activity_id = c.activity1\n" +
			"	INNER JOIN activities a2 ON a2.activity_id = c.activity2\n" +
			"	INNER JOIN groups_solutions gs ON gs.conflict_id = c.conflict_id\n" +
			"	INNER JOIN groups g ON gs.group_id = g.group_id\n" +
			"	INNER JOIN gt_users gtu ON gtu.id = gs.gt_user_id\n" +
			"ORDER BY created DESC, g.name, c.name";
}

ExtStore.generateStore(sql, request, out);
%>