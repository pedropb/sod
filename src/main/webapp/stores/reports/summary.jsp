<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "reports_summary", response, out)){
	return;
}

sql = 	"SELECT * FROM (SELECT\n" +
		"	'Usuários' AS name, COUNT(*) AS quantity\n" +
		"FROM\n" +
		"	users\n" +
		"UNION\n" +
		"SELECT\n" +
		"	'Grupos' AS name, COUNT(*) AS quantity\n" +
		"FROM\n" +
		"	groups\n" +
		"UNION\n" +
		"SELECT\n" +
		"	'Transações' AS name, COUNT(*) AS quantity\n" +
		"FROM\n" +
		"	transactions\n" +
		"UNION\n" +
		"SELECT\n" +
		"	'Atividades' AS name, COUNT(*) AS quantity\n" +
		"FROM\n" +
		"	activities\n" +
		"UNION\n" +
		"SELECT\n" +
		"	'Conflitos' AS name, COUNT(*) AS quantity\n" +
		"FROM\n" +
		"	conflicts\n" +
		"UNION\n" +
		"SELECT\n" +
		"	'Módulos' AS name, COUNT(*) AS quantity\n" +
		"FROM\n" +
		"	modules) t ORDER BY name";

ExtStore.generateStore(sql, request, out);
%>