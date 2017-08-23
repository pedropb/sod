<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String group_id = request.getParameter("group_id");
String exclude_group_id = request.getParameter("exclude_group_id");
String module_id = request.getParameter("module_id");
String exclude_module_id = request.getParameter("exclude_module_id");
String activity_id = request.getParameter("activity_id");
String exclude_activity_id = request.getParameter("exclude_activity_id");
String user_id = request.getParameter("user_id");
String exclude_user_id = request.getParameter("exclude_user_id");
String filter_activities = request.getParameter("filter_activities");
String exclude_transactions = request.getParameter("exclude_transactions");

String sql;

if (group_id != null) {
	if (!Permissions.canRead(session, "definitions_groups", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	t.activity_id,\n" +
			"	a.name AS activity,\n" +
			"	t.created\n" +
			"FROM\n" + 
			"	transactions t\n" +
			"	LEFT JOIN activities a ON a.activity_id = t.activity_id\n" +
			"	INNER JOIN groups_transactions gt ON t.transaction_id = gt.transaction_id\n" +
			"WHERE\n" + 
			"	gt.group_id = '" + StringEscapeUtils.escapeSql(group_id) + "'\n" +
			"ORDER BY\n" +
			"	id";
}
else if (exclude_group_id != null) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	t.activity_id,\n" +
			"	a.name AS activity,\n" +
			"	t.created\n" +
			"FROM\n" + 
			"	transactions t\n" +
			"	LEFT JOIN activities a ON a.activity_id = t.activity_id\n" +
			"WHERE\n" + 
			"	t.transaction_id NOT IN (	SELECT\n" + 
											"	t.transaction_id\n" +
											"FROM\n" + 
											"	transactions t\n" +
											"	INNER JOIN groups_transactions gt ON t.transaction_id = gt.transaction_id\n" +
											"WHERE\n" + 
											"	gt.group_id = '" + StringEscapeUtils.escapeSql(exclude_group_id) + "')\n" +
			"ORDER BY\n" +
			"	id";
}
else if (module_id != null) {
	if (!Permissions.canRead(session, "definitions_modules", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	t.activity_id,\n" +
			"	a.name AS activity,\n" +
			"	t.created\n" +
			"FROM\n" + 
			"	transactions t\n" +
			"	LEFT JOIN activities a ON a.activity_id = t.activity_id\n" +
			"	INNER JOIN modules_transactions mt ON t.transaction_id = mt.transaction_id\n" +
			"WHERE\n" + 
			"	mt.module_id = '" + StringEscapeUtils.escapeSql(module_id) + "'\n" +
			"ORDER BY\n" +
			"	id";
}
else if (exclude_module_id != null) {
	if (!Permissions.canWrite(session, "definitions_modules", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	t.activity_id,\n" +
			"	a.name AS activity,\n" +
			"	t.created\n" +
			"FROM\n" + 
			"	transactions t\n" +
			"	LEFT JOIN activities a ON a.activity_id = t.activity_id\n" +
			"WHERE\n" + 
			"	t.transaction_id NOT IN (	SELECT\n" + 
											"	t.transaction_id\n" +
											"FROM\n" + 
											"	transactions t\n" +
											"	INNER JOIN modules_transactions mt ON t.transaction_id = mt.transaction_id\n" +
											"WHERE\n" + 
											"	mt.module_id = '" + StringEscapeUtils.escapeSql(exclude_module_id) + "')\n" +
			"ORDER BY\n" +
			"	id";
}
else if (activity_id != null) {
	if (!Permissions.canRead(session, "definitions_activities", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	t.activity_id,\n" +
			"	a.name AS activity,\n" +
			"	t.created\n" +
			"FROM\n" + 
			"	transactions t\n" +
			"	LEFT JOIN activities a ON a.activity_id = t.activity_id\n" +
			"WHERE\n" + 
			"	a.activity_id = '" + StringEscapeUtils.escapeSql(activity_id) + "'\n" +
			"ORDER BY\n" +
			"	id";
}
else if (exclude_activity_id != null) {
	if (!Permissions.canWrite(session, "definitions_activities", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	t.activity_id,\n" +
			"	a.name AS activity,\n" +
			"	t.created\n" +
			"FROM\n" + 
			"	transactions t\n" +
			"	LEFT JOIN activities a ON a.activity_id = t.activity_id\n" +
			"WHERE\n" + 
			"	t.transaction_id NOT IN (	SELECT\n" + 
											"	t.transaction_id\n" +
											"FROM\n" + 
											"	transactions t\n" +
											"WHERE\n" + 
											"	t.activity_id = '" + StringEscapeUtils.escapeSql(exclude_activity_id) + "')\n" +
			"ORDER BY\n" +
			"	id";
}
else if (user_id != null) {
	if (!Permissions.canRead(session, "definitions_users", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	t.activity_id,\n" +
			"	a.name AS activity,\n" +
			"	ut.user_transaction,\n" +
			"	t.created\n" +
			"FROM\n" + 
			"	transactions t\n" +
			"	LEFT JOIN activities a ON a.activity_id = t.activity_id\n" +
			"	RIGHT JOIN (SELECT\n" + 
			"					transaction_id, \n" +
			"					TRUE AS user_transaction\n" +
			"				FROM\n" + 
			"					users_transactions ut\n" +
			"				WHERE\n" + 
			"					user_id = '" + StringEscapeUtils.escapeSql(user_id) + "'\n"+ 
			"				UNION\n" +
			"				SELECT\n" + 
			"					transaction_id, \n" +
			"					FALSE AS user_transaction \n" +
			"				FROM\n" + 
			"					groups_transactions gt\n" +
			"					INNER JOIN users_groups ug ON gt.group_id = ug.group_id\n" +
			"				WHERE\n" + 
			"					ug.user_id = '" + StringEscapeUtils.escapeSql(user_id) + "') ut ON t.transaction_id = ut.transaction_id\n" +
			"ORDER BY\n" +
			"	id";
}
else if (exclude_user_id != null) {
	if (!Permissions.canWrite(session, "definitions_groups", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	t.activity_id,\n" +
			"	a.name AS activity,\n" +
			"	t.created\n" +
			"FROM\n" + 
			"	transactions t\n" +
			"	LEFT JOIN activities a ON a.activity_id = t.activity_id\n" +
			"WHERE\n" + 
			"	t.transaction_id NOT IN (	SELECT\n" + 
			"									transaction_id \n" +
			"								FROM\n" + 
			"									users_transactions ut\n" +
			"								WHERE\n" + 
			"									user_id = '" + StringEscapeUtils.escapeSql(exclude_user_id) + "'\n"+ 
			"								UNION\n" +
			"								SELECT\n" + 
			"									transaction_id \n" +
			"								FROM\n" + 
			"									groups_transactions gt\n" +
			"									INNER JOIN users_groups ug ON gt.group_id = ug.group_id\n" +
			"								WHERE\n" + 
			"									ug.user_id = '" + StringEscapeUtils.escapeSql(exclude_user_id) + "'\n"+ 
			"							)\n" +
			"ORDER BY\n" +
			"	id";
}
else if (filter_activities != null) {
	String[] references = {
		"tools_create_groups",
		"tools_create_users"
	};
	
	if (!Permissions.canWrite(session, references, response, out)) {
		return;
	}
	
	String filterActivities = "";
	
	String[] ids = filter_activities.split("@@");
	String idSql = "";
	
	for (int i = 0; i < ids.length; i++) {
		if (i > 0) {
			idSql += ",";
		}
		
		idSql += "'" + StringEscapeUtils.escapeSql(ids[i]) + "'";
	}
	
	filterActivities = 	"	AND t.activity_id IN (" + idSql + ")\n" +
						"	AND t.activity_id IS NOT NULL\n";


	String excludeIds = "";
	if (exclude_transactions != null) {
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
		filterExclude = " AND transaction_id NOT IN (" + excludeIds + ")";
	}
	
	sql = 	"SELECT\n" + 
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	t.activity_id,\n" +
			"	a.name AS activity,\n" +
			"	t.created\n" +
			"FROM\n" + 
			"	transactions t\n" +
			"	LEFT JOIN activities a ON a.activity_id = t.activity_id\n" +
			"WHERE\n" + 
			"	TRUE\n" +
			filterExclude +
			filterActivities +
			"ORDER BY\n" +
			"	id";
}
else {
	if (!Permissions.canRead(session, "definitions_transactions", response, out)) {
		return;
	}

	sql = 	"SELECT\n" + 
			"	t.transaction_id AS id,\n" +
			"	t.name,\n" +
			"	t.activity_id,\n" +
			"	a.name AS activity,\n" +
			"	t.created\n" +
			"FROM\n" + 
			"	transactions t\n" +
			"	LEFT JOIN activities a ON a.activity_id = t.activity_id\n" +
			"ORDER BY\n" +
			"	id";
}

ExtStore.generateStore(sql, request, out);
%>