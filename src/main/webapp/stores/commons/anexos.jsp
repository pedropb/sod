<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<% 
	String origem = request.getParameter("origem");
	String identificador = request.getParameter("identificador");

	if (origem == null || origem.length() == 0 || identificador == null || identificador.length() == 0) {
		response.setStatus(400);
		return;
	}
		
	String userId;
	if (session.getAttribute("userId") instanceof Integer)
		userId = (Integer) session.getAttribute("userId") + "";
	else if (session.getAttribute("userId") instanceof String)
		userId = (String) session.getAttribute("userId");
	else {
		Permissions.outputError(response, out);
		return;
	}

	String filtroUsuario = "	AND a.usuario_id = " + userId + "\n";	
	if (Permissions.canRead(session, "config_anexos_terceiros"))
		filtroUsuario = "";
	
	String sql =	"SELECT\n" +
					"	a.anexo_id AS id,\n" + 
					"	a.nome AS nome,\n" +
					"	a.descricao AS descricao,\n" +
					"	u.nome AS usuario,\n" +
					"	u.id AS usuario_id,\n" +
					"	a.data_registro AS data_registro\n" +
					"FROM\n" +
					"	anexos a\n" +
					"	INNER JOIN usuario u ON a.usuario_id = u.id\n" +
					"WHERE\n" +
					"	a."+ origem +" = "+ identificador +"\n" +
					filtroUsuario +
					"ORDER BY\n" +
					"	data_registro DESC,\n" +
					"	descricao";
	
	ExtStore.generateStore(sql, request, out);
%>