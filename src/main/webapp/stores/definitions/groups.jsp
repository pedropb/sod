<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String user_id = request.getParameter("user_id");
String exclude_user_id = request.getParameter("exclude_user_id");
String filter_activities = request.getParameter("filter_activities");
String exclude_users = request.getParameter("exclude_users");

String sql;

if (user_id != null) {
	if (!Permissions.canWrite(session, "definitions_users", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	g.group_id AS id,\n" +
			"	g.name,\n" +
			"	g.created\n" +
			"FROM\n" + 
			"	groups g\n" +
			"	INNER JOIN users_groups ug ON g.group_id = ug.group_id\n" +
			"WHERE\n" + 
			"	ug.user_id = '" + StringEscapeUtils.escapeSql(user_id) + "'\n" +
			"ORDER BY\n" +
			"	id";
}
else if (exclude_user_id != null) {
	if (!Permissions.canWrite(session, "definitions_users", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	g.group_id AS id,\n" +
			"	g.name,\n" +
			"	g.created\n" +
			"FROM\n" + 
			"	groups g\n" +
			"WHERE\n" + 
			"	g.group_id NOT IN (	SELECT\n" + 
									"	g.group_id\n" +
									"FROM\n" + 
									"	groups g\n" +
									"	INNER JOIN users_groups ug ON g.group_id = ug.group_id\n" +
									"WHERE\n" + 
									"	ug.user_id = '" + StringEscapeUtils.escapeSql(exclude_user_id) + "')\n" +
			"ORDER BY\n" +
			"	id";
}
else if (filter_activities != null) {
	if (!Permissions.canWrite(session, "tools_create_users", response, out)) {
		return;
	}
	
	String[] ids = filter_activities.split("@@");
	String filterIds = "";
	for (int i = 0; i < ids.length; i++) {
		if (i > 0) {
			filterIds += ",";
		}
		
		filterIds += "'" + StringEscapeUtils.escapeSql(ids[i]) + "'";
	}
	
	String excludeIds = "";
	if (exclude_users != null) {
		ids = filter_activities.split("@@");
		
		for (int i = 0; i < ids.length; i++) {
			if (i > 0) {
				excludeIds += ",";
			}
			
			excludeIds += "'" + StringEscapeUtils.escapeSql(ids[i]) + "'";
		}
	}
	String filterExclude = "";
	if (excludeIds.length() > 0) {
		filterExclude = " AND group_id NOT IN (" + excludeIds + ")";
	}
	
	sql = 	"(SELECT DISTINCT\n" + 
			"	g.group_id AS id,\n" +
			"	g.name,\n" +
			"	g.created\n" +
			"FROM\n" + 
			"	groups g\n" +
			"	INNER JOIN groups_activities ga ON ga.group_id = g.group_id\n" +
			"WHERE\n" + 
			"	ga.activity_id IN (" + filterIds + ")\n" +
			filterExclude +
			"EXCEPT\n" +
			"SELECT DISTINCT\n" + 
			"	g.group_id AS id,\n" +
			"	g.name,\n" +
			"	g.created\n" +
			"FROM\n" + 
			"	groups g\n" +
			"	INNER JOIN groups_activities ga ON ga.group_id = g.group_id\n" +
			"WHERE\n" + 
			"	ga.activity_id NOT IN (" + filterIds + ")\n" +
			") ORDER BY\n" +
			"	id";
}
else {
	String[] references = {
		"definitions_groups",
		"tools_create_groups"
	};
	
	if (!Permissions.canRead(session, references, response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	group_id AS id,\n" +
			"	name,\n" +
			"	created\n" +
			"FROM\n" + 
			"	groups\n" +
			"ORDER BY\n" +
			"	id";
}

ExtStore.generateStore(sql, request, out);
%>