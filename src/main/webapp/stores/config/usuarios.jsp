<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%
String[] permissions = new String[] {"config_usuarios", "config_lembretes"};
if (!Permissions.canRead(session,  permissions, response, out)) {
	return;
}

String all_users = request.getParameter("filtro");
boolean f = all_users != null && all_users.equals("on");

String sql = 	"SELECT\n" + 
				"	u.id,\n" +
				"	u.login,\n" +
				"	u.active AS ativo,\n" +
				"	CASE WHEN ug.group_id IS NULL THEN -1 ELSE ug.group_id END AS grupo\n" +
				"FROM\n" + 
				"	gt_users u\n" +
				"	LEFT JOIN (SELECT user_id, MAX(group_id) group_id FROM gt_users_groups GROUP BY user_id) ug ON u.id = ug.user_id\n" +
				"WHERE\n" +
				"	u.id > 0\n" +
				"	AND u.initialized = TRUE\n" +
				(f ? "" : "AND u.active = TRUE\n") +
				"ORDER BY\n" +
				"	u.login";

ExtStore.generateStore(sql, request, out);
%>