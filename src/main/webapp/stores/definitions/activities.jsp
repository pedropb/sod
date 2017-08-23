<%@page import="geotech.Utils"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

String exclude_activities_id = request.getParameter("exclude_activities_id");

if (exclude_activities_id != null) {
	String[] references = {
		"tools_create_groups",
		"tools_create_users"
	};
	
	if (!Permissions.canWrite(session, references, response, out)) {
		return;
	}
	
	String[] ids = exclude_activities_id.split("@@");
	String idSql = "";
	
	for (int i = 0; i < ids.length; i++) {
		if (i > 0) {
			idSql += ",";
		}
		
		idSql += "'" + StringEscapeUtils.escapeSql(ids[i]) + "'";
	}

	sql = 	"SELECT\n" + 
			"	activity_id AS id,\n" +
			"	name,\n" +
			"	created\n" +
			"FROM\n" + 
			"	activities\n" +
			"WHERE\n" + 
			"	activity_id NOT IN ("+ idSql +")\n" +
			"ORDER BY\n" +
			"	id";
}
else {
	String[] references = {
		"definitions_transactions",
		"definitions_conflicts"
	};

	if (!Permissions.canRead(session, "definitions_activities")
		&& !Permissions.canWrite(session, references)) {
		Permissions.outputError(response, out);
		return;
	}

	sql = 	"SELECT\n" + 
			"	activity_id AS id,\n" +
			"	name,\n" +
			"	created\n" +
			"FROM\n" + 
			"	activities\n" +
			"ORDER BY\n" +
			"	id";
}


ExtStore.generateStore(sql, request, out);
%>