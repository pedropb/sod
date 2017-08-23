<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "definitions_modules", response, out)) {
	return;
}

sql = 	"SELECT\n" + 
		"	module_id AS id,\n" +
		"	name,\n" +
		"	created\n" +
		"FROM\n" + 
		"	modules\n" +
		"ORDER BY\n" +
		"	id";

ExtStore.generateStore(sql, request, out);
%>