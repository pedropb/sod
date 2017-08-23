<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "tools_solve_conflicts", response, out)) {
	return;
}

String userId = request.getParameter("user_id");
String conflictId = request.getParameter("conflict_id");
String activityNo = request.getParameter("activity");

if (userId == null || conflictId == null || activityNo == null) {
	Permissions.outputError(response, out);
	return;
}

sql = 	"SELECT\n" +
		"	g.group_id AS id,\n" + 
		"	g.name\n" +
		"FROM\n" +
		"	groups g\n" +
		"	INNER JOIN groups_activities ga ON ga.group_id = g.group_id\n" +
		"	INNER JOIN users_groups ug ON ug.group_id = g.group_id\n" +
		"WHERE\n" +
		"	ga.activity_id = (SELECT activity"+ activityNo +" FROM conflicts WHERE conflict_id = '"+ StringEscapeUtils.escapeSql(conflictId) + "')\n" +
		"	AND ug.user_id = '" + StringEscapeUtils.escapeSql(userId) + "'\n" +
		"ORDER BY id";

ExtStore.generateStore(sql, request, out);
%>