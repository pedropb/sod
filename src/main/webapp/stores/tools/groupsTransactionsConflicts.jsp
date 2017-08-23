<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "tools_solve_conflicts", response, out)) {
	return;
}

String groupId = request.getParameter("group_id");
String conflictId = request.getParameter("conflict_id");
String activityNo = request.getParameter("activity");

if (groupId == null || conflictId == null || activityNo == null) {
	Permissions.outputError(response, out);
	return;
}

sql = 	"SELECT\n" +
		"	t.transaction_id AS id,\n" + 
		"	t.name\n" +
		"FROM\n" +
		"	transactions t\n" +
		"	INNER JOIN groups_transactions gt ON gt.transaction_id = t.transaction_id\n" +
		"WHERE\n" +
		"	t.activity_id = (SELECT activity"+ activityNo +" FROM conflicts WHERE conflict_id = '"+ StringEscapeUtils.escapeSql(conflictId) + "')\n" +
		"	AND gt.group_id = '" + StringEscapeUtils.escapeSql(groupId) + "'\n" +
		"ORDER BY id";

ExtStore.generateStore(sql, request, out);
%>