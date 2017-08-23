<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "tools_changelog", response, out)) {
	return;
}

sql = 	"SELECT\n" + 
		"	l.log_id AS id,\n" +
		"	u.login AS user,\n" +
		"	l.module,\n" +
		"	l.operation,\n" +
		"	l.description,\n" +
		"	l.form,\n" +
		"	l.created\n" +
		"FROM\n" + 
		"	log l INNER JOIN gt_users u ON u.id = l.gt_user_id \n" +
		"ORDER BY\n" +
		"	created DESC";

ExtStore.generateStore(sql, request, out);
%>