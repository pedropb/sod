<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "tools_solve_conflicts", response, out)) {
	return;
}

if (request.getParameter("groupBy") == null) {
	Permissions.outputError(response, out);
	return;
}

String groupBy = request.getParameter("groupBy");

if (groupBy.equals("Usuário")) {
	sql = 	"SELECT\n" +
			"	t.conflict_id,\n" +
			"	t.conflict,\n" +
			"	t.activity1,\n" +
			"	t.activity2,\n" +
			"	t.name,\n" +
			"	t.user_id,\n" +
			"	us.user_id IS NOT NULL AS accepted,\n" +
			"	us.reason,\n" +
			"	TO_CHAR(us.reason_created, 'dd/mm/yyyy') AS reason_created,\n" +
			"	gtu.login AS gt_user\n" +
			"FROM\n" +
			"(SELECT\n" +
			"	c.conflict_id,\n" +
			"	c.name AS conflict,\n" +
			"	a.name AS activity1,\n" +
			"	a2.name AS activity2,\n" +
			"	u.name,\n" +
			"	ua.user_id\n" +
			"FROM\n" +
			"	conflicts c\n" +
			"	INNER JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua ON ua.activity_id = c.activity1\n" +
			"	INNER JOIN activities a ON a.activity_id = c.activity1\n" +
			"	INNER JOIN (SELECT user_id, activity_id FROM users_activities UNION SELECT ug.user_id, ga.activity_id FROM users_groups ug INNER JOIN groups_activities ga ON ug.group_id = ga.group_id) ua2 ON ua2.activity_id = c.activity2\n" +
			"	INNER JOIN activities a2 ON a2.activity_id = c.activity2\n" +
			"	INNER JOIN users u ON ua.user_id = u.user_id\n" +
			"WHERE\n" +
			"	ua.user_id = ua2.user_id) t\n" +
			"	LEFT JOIN users_solutions us ON us.conflict_id = t.conflict_id AND us.user_id = t.user_id\n" +
			"	LEFT JOIN gt_users gtu ON gtu.id = us.gt_user_id\n" +
			"ORDER BY name, conflict";
}
else {
	sql = 	"SELECT\n" +
			"	c.conflict_id,\n" +
			"	c.name AS conflict,\n" +
			"	a.name AS activity1,\n" +
			"	a2.name AS activity2,\n" +
			"	g.name,\n" +
			"	ga.group_id,\n" +
			"	gs.group_id IS NOT NULL AS accepted,\n" +
			"	gs.reason,\n" +
			"	TO_CHAR(gs.reason_created, 'dd/mm/yyyy') AS reason_created,\n" +
			"	gtu.login AS gt_user\n" +
			"FROM\n" +
			"	conflicts c\n" +
			"	INNER JOIN groups_activities ga ON ga.activity_id = c.activity1\n" +
			"	INNER JOIN activities a ON a.activity_id = c.activity1\n" +
			"	INNER JOIN groups_activities ga2 ON ga2.activity_id = c.activity2\n" +
			"	INNER JOIN activities a2 ON a2.activity_id = c.activity2\n" +
			"	INNER JOIN groups g ON ga.group_id = g.group_id\n" +
			"	LEFT JOIN groups_solutions gs ON gs.conflict_id = c.conflict_id AND gs.group_id = g.group_id\n" +
			"	LEFT JOIN gt_users gtu ON gtu.id = gs.gt_user_id\n" +
			"WHERE\n" +
			"	ga.group_id = ga2.group_id\n" +
			"ORDER BY name, conflict";
}

ExtStore.generateStore(sql, request, out);
%>