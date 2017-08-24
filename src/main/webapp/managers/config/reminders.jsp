<%@page import="alttus.reminders.ReminderController"%>
<%@page import="geotech.Utils"%>
<%@page import="geotech.Logger"%>
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

String userId =  (String) session.getAttribute("userId");

Database db = Database.createDatabase();
Logger logger = new Logger(session);
	
String sql;
ResultSet result;

if (action.equals("add") && request.getParameter("ids") != null) {
	if (!Permissions.canWrite(session, "config_lembretes", response, out))
		return;
	
	String[] ids = request.getParameter("ids").split("@\\*@");
	
	sql = "INSERT INTO reminders(message, recipient_id, author_id, next_alarm, repeat) VALUES ";
	
	String message = StringEscapeUtils.escapeSql(request.getParameter("message"));
	String next_alarm = "TO_DATE('" + request.getParameter("next_alarm") + "', 'DD/MM/YYYY')";
	String repeat = request.getParameter("repeat");
	
	for (int i = 0; i < ids.length; i++) {
		if (i > 0)
			sql += ",";
		
		sql += "('" + message + "', " + ids[i] + ", " + userId + ", " + next_alarm + ", " + repeat + ")"; 
	}
	
	if (db.update(sql) > 0) {
		output.object();
		output.key("success").value(true);
		output.key("message").value("Lembretes criados com sucesso.");
		output.endObject();
	}
	else {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Ocorreram erros durante a criação dos lembretes.");
		output.endObject();
	}
}
else if (action.equals("dismiss") && request.getParameter("id") != null) {
	String id = request.getParameter("id");
	
	ReminderController rc = new ReminderController();
	boolean success = rc.dismissReminder(id, userId);
	
	output.object();
	output.key("success").value(success);
	output.key("message").value("Lembretes dispensados com sucesso.");
	output.endObject();
}
else if (action.equals("remove") && request.getParameter("ids") != null) {
	if (!Permissions.canWrite(session, "config_lembretes", response, out))
		return;
	
	String[] ids = request.getParameter("ids").split("@\\*@");
	
	sql = "DELETE FROM reminders WHERE reminder_id IN (" + Utils.join(ids, ",") + ")";
	db.update(sql);
	
	output.object();
	output.key("success").value(true);
	output.key("message").value("Lembretes removidos com sucesso.");
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