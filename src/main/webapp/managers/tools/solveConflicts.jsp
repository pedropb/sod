<%@page import="geotech.Logger"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="geotech.Permissions"%>
<%@page import="org.json.JSONWriter"%>
<%@page import="geotech.Database"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%
String action = request.getParameter("action");

JSONWriter output = new JSONWriter(out);

if (action == null) {
	response.setStatus(400);
	
	output.object();
	output.key("success").value(false);
	output.key("message").value("Action é obrigatório");
	output.endObject();
	
	return;
}

Database db = Database.createDatabase();
Logger logger = new Logger(session);
ResultSet result;
	
String sql;

if (action.equals("remove")) {
	if (!Permissions.canWrite(session, "tools_solve_conflicts", response, out))
		return;
	
	String origin = request.getParameter("origin");
	String originId = request.getParameter("origin_id");
	String type = request.getParameter("type");
	String typeId = request.getParameter("type_id");
	
	if (origin != null && originId != null && type != null && typeId != null &&
		((origin.equals("user") || origin.equals("group")) && (type.equals("transaction") || type.equals("group")))) {
		
		sql = "DELETE FROM " + origin + "s_" + type + "s WHERE " + origin + "_id = '" + StringEscapeUtils.escapeSql(originId) + "' AND " + type + "_id = '" + StringEscapeUtils.escapeSql(typeId) + "'";
		if (db.update(sql) == 1) {
			output.object();
			output.key("success").value(true);
			output.endObject();

			String conflictId = request.getParameter("conflict_id");
			String removedOrigin = origin.equals("user") ? "usuário" : "grupo";
			String removedType = type.equals("transaction") ? "da transação" : "do grupo";
			
			logger.log("Remoção " + removedType + " " + typeId + " do " + removedOrigin + " " + originId + " para resolução do conflito " + conflictId + ".", "Ferramentas", "Resolução de Conflitos", "DELETE");
		}
		else {
			output.object();
			output.key("success").value(false);
			output.key("message").value("Não foi possível remover o registro selecionado. Verifique se ele ainda existe.");
			output.endObject();
		}
		
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Parâmetros incorretos");
		output.endObject();
	}
}
else if (action.equals("accept")) {
	if (!Permissions.canWrite(session, "tools_solve_conflicts", response, out))
		return;
	
	String origin = request.getParameter("origin");
	String originId = request.getParameter("origin_id");
	String conflictId = request.getParameter("conflict_id");
	String reason = request.getParameter("reason");
	
	if (origin != null && originId != null && conflictId != null && reason != null && (origin.equals("user") || origin.equals("group"))) {
		
		db.setAutoCommit(false);
		sql = 	"INSERT INTO " + origin + "s_solutions(" + origin + "_id, conflict_id, reason, gt_user_id)\n" +
				"VALUES ('" + StringEscapeUtils.escapeSql(originId) + "', '" + StringEscapeUtils.escapeSql(conflictId) + "', '" + StringEscapeUtils.escapeSql(reason) + "', " + session.getAttribute("userId") + ")";
		
		int automaticAcceptionCount = 0;
		if (db.update(sql) == 1) {
			
			// testa aceite automático de grupos
			if (origin.equals("group")) {
				
				// o aceite automático deve ser feito a todos os usuários do grupo que estejam em conflito
				// e o único conflito seja a sua presenção no grupo.
				// Por exemplo: Usuário U está somente no grupo G e não tem mais nenhuma transação.
				// O grupo G tem transações das atividades A1 e A2 que são conflitantes segundo o conflito C1.
				// Assim, quando o conflito C1 for aceito para o grupo G, o conflito U-C1 deve ser aceito implicitamente
				
				sql = "SELECT activity1, activity2 FROM conflicts WHERE conflict_id = '" + StringEscapeUtils.escapeSql(conflictId) + "'";
				result = db.query(sql);
				result.next();
				String activity1 = result.getString("activity1");
				String activity2 = result.getString("activity2");
				
				List<String> users = new ArrayList<String>(); 
				
				sql = "SELECT user_id FROM users_groups WHERE group_id = '" + StringEscapeUtils.escapeSql(originId) + "'";
				result = db.query(sql);
				while (result.next()) {
					String userId = result.getString("user_id");
					
					// Verifica se o usuário pertence a outros grupos que executam atividades do conflito
					sql = 	"SELECT\n" +
							"	COUNT(*)\n" +
							"FROM\n" +
							"	users_groups ug\n" +
							"	INNER JOIN groups_activities ga ON ga.group_id = ug.group_id\n" + 
							"WHERE\n" +
							"	ug.user_id = '" + StringEscapeUtils.escapeSql(userId) + "'\n" +
							"	AND ug.group_id != '" + StringEscapeUtils.escapeSql(originId) + "'\n" +
							"	AND (ga.activity_id = '" + StringEscapeUtils.escapeSql(activity1) + "' OR ga.activity_id = '" + StringEscapeUtils.escapeSql(activity2) + "')";
					
					ResultSet result2 = db.query(sql);
					result2.next();
					if (result2.getInt(1) > 0) {
						// se existem grupos, então o conflito do usuário não deve receber o aceite automático
						continue;
					}
					
					// Verifica se o usuário tem transações vinculadas a atividades do conflito
					sql = 	"SELECT\n" +
							"	COUNT(*)\n" +
							"FROM\n" +
							"	users_transactions ut\n" +
							"	INNER JOIN (SELECT * FROM transactions WHERE transaction_id NOT IN (SELECT transaction_id FROM groups_transactions WHERE group_id = '" + StringEscapeUtils.escapeSql(originId) + "')) t ON t.transaction_id = ut.transaction_id\n" + 
							"WHERE\n" +
							"	ut.user_id = '" + StringEscapeUtils.escapeSql(userId) + "'\n" +
							"	AND (t.activity_id = '" + StringEscapeUtils.escapeSql(activity1) + "' OR t.activity_id = '" + StringEscapeUtils.escapeSql(activity2) + "')";
					
					result2 = db.query(sql);
					result2.next();
					if (result2.getInt(1) > 0) {
						// se existem transações, então o conflito do usuário não deve receber o aceite automático
						continue;
					}
					
					users.add(userId);
				}
				
				// gerando aceites automáticos
				for (int i = 0 ; i < users.size(); i++) {
					sql = 	"INSERT INTO users_solutions(user_id, conflict_id, reason, gt_user_id)\n" +
							"VALUES ('" + StringEscapeUtils.escapeSql(users.get(i)) + "', '" + StringEscapeUtils.escapeSql(conflictId) + "', 'Aceite automático gerado pelo aceite do grupo \"" + StringEscapeUtils.escapeSql(originId) + "\".', " + session.getAttribute("userId") + ")";
					automaticAcceptionCount = db.update(sql);
				}
			}
			
			output.object();
			output.key("success").value(true);
			output.endObject();
			
			db.commit();

			String acceptedOrigin = origin.equals("user") ? "usuário" : "grupo";
			String autoAccept = "";
			if (automaticAcceptionCount > 0) {
				autoAccept = "\nAceites automáticos gerados: " + automaticAcceptionCount + ".";
			}
			logger.log("Aceite do conflito " + conflictId + " para o " + acceptedOrigin + " " + originId + ".\nMotivo: " + reason + "." + autoAccept, "Ferramentas", "Resolução de Conflitos", "INSERT");
		}
		else {
			output.object();
			output.key("success").value(false);
			output.key("message").value("Ocorreram erros durante a aceitação do conflito. Tente novamente mais tarde.");
			output.endObject();
			
			db.rollback();
		}
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Parâmetros incorretos");
		output.endObject();
	}
}
else if (action.equals("remove_accept")) {
	if (!Permissions.canWrite(session, "tools_solve_conflicts", response, out))
		return;
	
	String origin = request.getParameter("origin");
	String originId = request.getParameter("origin_id");
	String conflictId = request.getParameter("conflict_id");
	
	if (origin != null && originId != null && conflictId != null && (origin.equals("user") || origin.equals("group"))) {
		
		sql = 	"DELETE FROM " + origin + "s_solutions\n" +
				"WHERE\n" +
				"	conflict_id = '" + StringEscapeUtils.escapeSql(conflictId) + "'\n" + 
				"	AND "+ origin + "_id = '" + StringEscapeUtils.escapeSql(originId) + "'";
		
		if (db.update(sql) == 1) {
			output.object();
			output.key("success").value(true);
			output.endObject();
			
			String acceptedOrigin = origin.equals("user") ? "usuário" : "grupo";
			logger.log("Remoção do aceite do conflito " + conflictId + " para o " + acceptedOrigin + " " + originId + ".", "Ferramentas", "Resolução de Conflitos", "DELETE");
		}
		else {
			output.object();
			output.key("success").value(false);
			output.key("message").value("Ocorreram erros durante a remoção do aceite. Tente novamente mais tarde.");
			output.endObject();
		}
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Parâmetros incorretos");
		output.endObject();
	}
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