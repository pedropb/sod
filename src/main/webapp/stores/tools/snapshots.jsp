<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

String[] references = {
	"tools_snapshots",
	"dashboard"
};

if (!Permissions.canRead(session, references, response, out)) {
	return;
}

sql = 	"SELECT\n" + 
		"	snapshot_id AS id,\n" +
		"	users_conflicts,\n" +
		"	accepted_users_conflicts,\n" +
		"	groups_conflicts,\n" +
		"	accepted_groups_conflicts,\n" +
		"	created\n" +
		"FROM\n" + 
		"	snapshots\n" +
		"ORDER BY\n" +
		"	id";

ExtStore.generateStore(sql, request, out);
%>