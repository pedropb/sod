<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "config_lembretes", response, out)) {
	return;
}

sql = 	"SELECT\n" + 
		"	r.reminder_id AS id,\n" +
		"	r.message,\n" +
		"	r.created,\n" +
		"	r.next_alarm,\n" +
		"	r.last_viewed,\n" +
		"	rec.login AS recipient,\n" +
		"	aut.login AS author,\n" +
		"	r.dismissed,\n" +
		"	r.repeat\n" +
		"FROM\n" + 
		"	reminders r \n" +
		"	INNER JOIN gt_users rec ON rec.id = r.recipient_id \n" +
		"	INNER JOIN gt_users aut ON aut.id = r.recipient_id \n" +
		"ORDER BY\n" +
		"	created DESC, id DESC";

ExtStore.generateStore(sql, request, out);
%>