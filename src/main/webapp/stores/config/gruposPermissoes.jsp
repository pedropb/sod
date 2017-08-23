<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<% 
if (!Permissions.canRead(session, "config_grupos_permissoes", response, out)) {
	return;
}

String sql = 	"SELECT\n" + 
				"	g.id,\n" +
				"	g.user_group AS grupo,\n" +
				"	g.description AS descricao\n" +
				"FROM\n" + 
				"	gt_user_groups g\n" +
				"ORDER BY\n" +
				"	g.user_group";

ExtStore.generateStore(sql, request, out);
%>