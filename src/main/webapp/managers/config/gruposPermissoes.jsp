<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSetMetaData"%>
<%@page import="geotech.Permissions"%>
<%@page import="org.json.JSONWriter"%>
<%@page import="geotech.Database"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%
String action = request.getParameter("action");

JSONWriter output = new JSONWriter(out);

if (!Permissions.canWrite(session, "config_grupos_permissoes", response, out))
	return;

if (action == null) {
	response.setStatus(400);

	output.object();
	output.key("success").value(false);
	output.key("message").value("Action é obrigatório");
	output.endObject();

	return;
}

Database db = Database.createDatabase();

String sql;

if (action.equals("add")) {
   	// inserir grupo no banco
   	sql = "INSERT INTO gt_user_groups (initialized) VALUES (FALSE)";
   	if (db.update(sql) > 0) {
   		sql = 	"SELECT\n" +
				"	g.id,\n" +
				"	g.user_group AS grupo,\n" +
				"	g.description AS descricao\n" +
				"FROM\n" +
				"	gt_user_groups g\n" +
				"WHERE\n" +
				"	g.id = CURRVAL('gt_user_groups_id_seq')";

		ResultSet result = db.query(sql);

		ResultSetMetaData metadata = result.getMetaData();
		int columnCount = metadata.getColumnCount();
		String[] columns = new String[columnCount];
		for (int i = 0; i < columnCount; i++) {
			columns[i] = metadata.getColumnName(i + 1);
		}

		if (result.next()) {
			output.object();
			output.key("success").value(true);
			output.key("record").object();

			for (int i = 0; i < columnCount; i++) {
				output.key(columns[i]).value(result.getObject(columns[i]));
			}

			output.endObject();
			output.endObject();
		}
		else {
			output.object();
			output.key("success").value(false);
			output.key("message").value("Não foi possível acessar o registro no banco de dados. Se o problema persistir, entre em contato com o administrador do sistema.");
			output.endObject();
		}
   	}
   	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível criar o registro no banco de dados. Se o problema persistir, entre em contato com o administrador do sistema.");
		output.endObject();
	}
}
else if (action.equals("edit") && request.getParameter("id") != null) {
	String groupId = request.getParameter("id");
	String group = request.getParameter("grupo");
	String description = request.getParameter("descricao");

   	if (groupId == null || groupId.isEmpty()){
	 	response.setStatus(500);

		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível atualizar o grupo de permissões selecionado. Se o problema persistir, entre em contato com o administrador do sistema.");
		output.endObject();

   		db.close();
		return;
   	}

	sql = "UPDATE gt_user_groups\n" +
				 "SET user_group = '" + StringEscapeUtils.escapeSql(group) + "',\n" +
				 "	  description = '" + StringEscapeUtils.escapeSql(description) + "',\n" +
				 "	  initialized = TRUE\n" +
				 "WHERE id = " + groupId;
   	db.update(sql);

	Permissions.updateGroupPermissions(request, groupId);

	output.object();
	output.key("success").value(true);
	output.key("message").value("Grupo de Permissões atualizado com sucesso.");
	output.endObject();
}
else if (action.equals("checkConstraints") && request.getParameter("id") != null) {
	String id = request.getParameter("id");
	ResultSet result;
	int sum = 0;
	boolean error = false;

	sql = "SELECT COUNT(*) AS num FROM gt_users_groups WHERE group_id = " + id;
	result = db.query(sql);
	if (result.next()) {
		sum += result.getInt("num");
	}
	else {
		error = true;
	}

	if (!error) {
		output.object();
		output.key("success").value(true);
		output.key("count").value(sum);
		output.endObject();
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Não foi possível verificar as restrições. Se o problema persistir, entre em contato com o administrador do sistema.");
		output.endObject();
	}
}
else if (action.equals("remove") && request.getParameter("id") != null) {
	String id = request.getParameter("id");

	sql = "DELETE FROM gt_users_groups WHERE group_id = " + id;
	db.update(sql);

	sql = "DELETE FROM gt_user_groups WHERE id = " + id;
	db.update(sql);

	output.object();
	output.key("success").value(true);
	output.key("message").value("Grupo de Permissões removido com sucesso.");
	output.endObject();
}
else {
	response.setStatus(400);

	output.object();
	output.key("success").value(false);
	output.key("message").value("Parâmetros incorretos");
	output.endObject();
}

db.close();
%>
