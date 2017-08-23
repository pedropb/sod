<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String group_id = request.getParameter("group_id");
String exclude_group_id = request.getParameter("exclude_group_id");
String filter_activities = request.getParameter("filter_activities");
String exclude_users = request.getParameter("exclude_users");

String sql;

if (group_id != null) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	u.user_id AS id,\n" +
			"	u.name,\n" +
			"	u.created\n" +
			"FROM\n" + 
			"	users u\n" +
			"	INNER JOIN users_groups ug ON u.user_id = ug.user_id\n" +
			"WHERE\n" + 
			"	ug.group_id = '" + StringEscapeUtils.escapeSql(group_id) + "'\n" +
			"ORDER BY\n" +
			"	id";
}
else if (exclude_group_id != null) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	u.user_id AS id,\n" +
			"	u.name,\n" +
			"	u.created\n" +
			"FROM\n" + 
			"	users u\n" +
			"WHERE\n" + 
			"	u.user_id NOT IN (	SELECT\n" + 
									"	u.user_id\n" +
									"FROM\n" + 
									"	users u\n" +
									"	INNER JOIN users_groups ug ON u.user_id = ug.user_id\n" +
									"WHERE\n" + 
									"	ug.group_id = '" + StringEscapeUtils.escapeSql(exclude_group_id) + "')\n" +
			"ORDER BY\n" +
			"	id";
}
else if (filter_activities != null) {
	if (!Permissions.canWrite(session, "tools_create_groups", response, out)) {
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
		filterExclude = " AND u.user_id NOT IN (" + excludeIds + ")";
	}
	
	String usersActivitiesSql = "SELECT DISTINCT\n" +
								"	ua.user_id,\n" +
								"	ua.activity_id\n" +
								"FROM\n" +
								"	users_activities ua\n" +
								"UNION\n" +
								"SELECT DISTINCT\n" +
								"	ug.user_id,\n" +
								"	ga.activity_id\n" +
								"FROM\n" +
								"	users_groups ug\n" +
								"	INNER JOIN groups_activities ga ON  ug.group_id = ga.group_id";
	
	sql = 	"(SELECT DISTINCT\n" + 
			"	u.user_id AS id,\n" +
			"	u.name,\n" +
			"	u.created\n" +
			"FROM\n" + 
			"	users u\n" +
			"	INNER JOIN ( " + usersActivitiesSql + " ) ua ON ua.user_id = u.user_id\n" +
			"WHERE\n" + 
			"	ua.activity_id IN (" + filterIds + ")\n" +
			filterExclude +
			"EXCEPT\n" +
			"SELECT DISTINCT\n" + 
			"	u.user_id AS id,\n" +
			"	u.name,\n" +
			"	u.created\n" +
			"FROM\n" + 
			"	users u\n" +
			"	INNER JOIN ( " + usersActivitiesSql + " ) ua ON ua.user_id = u.user_id\n" +
			"WHERE\n" + 
			"	ua.activity_id NOT IN (" + filterIds + ")\n" +
			") ORDER BY\n" +
			"	id";
}
else {
	String[] references = {
		"definitions_users",
		"tools_create_users"
	};
		
	if (!Permissions.canRead(session, references, response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	user_id AS id,\n" +
			"	name,\n" +
			"	created\n" +
			"FROM\n" + 
			"	users\n" +
			"ORDER BY\n" +
			"	id";
}

ExtStore.generateStore(sql, request, out);
%>