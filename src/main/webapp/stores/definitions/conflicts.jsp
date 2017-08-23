<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String activity_id = request.getParameter("activity_id");
String sql;

if (activity_id != null) {
	if (!Permissions.canWrite(session, "definitions_activities", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	c.conflict_id AS id,\n" +
			"	c.name,\n" +
			"	c.activity1 AS activity1_id,\n" +
			"	a1.name AS activity1,\n" +
			"	c.activity2 AS activity2_id,\n" +
			"	a2.name AS activity2,\n" +
			"	c.created\n" +
			"FROM\n" + 
			"	conflicts c\n" +
			"	LEFT JOIN activities a1 ON a1.activity_id = c.activity1\n" +
			"	LEFT JOIN activities a2 ON a2.activity_id = c.activity2\n" +
			"WHERE\n" + 
			"	c.activity1 = '" + StringEscapeUtils.escapeSql(activity_id) + "'\n" +
			"	OR c.activity2 = '" + StringEscapeUtils.escapeSql(activity_id) + "'\n" +
			"ORDER BY\n" +
			"	id";
}
else {
	if (!Permissions.canRead(session, "definitions_conflicts", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	c.conflict_id AS id,\n" +
			"	c.name,\n" +
			"	c.activity1 AS activity1_id,\n" +
			"	a1.name AS activity1,\n" +
			"	c.activity2 AS activity2_id,\n" +
			"	a2.name AS activity2,\n" +
			"	c.created\n" +
			"FROM\n" + 
			"	conflicts c\n" +
			"	LEFT JOIN activities a1 ON a1.activity_id = c.activity1\n" +
			"	LEFT JOIN activities a2 ON a2.activity_id = c.activity2\n" +
			"ORDER BY\n" +
			"	id";
}

ExtStore.generateStore(sql, request, out);
%>