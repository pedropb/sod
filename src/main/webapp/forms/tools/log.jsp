<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
JSONWriter output = new JSONWriter(out);

if (!Permissions.canRead(session, "tools_changelog", response, out)) {
	return;
}

// Não utilizado por enquanto
// boolean canWriteLog = Permissions.canWrite(session, "tools_changelog");

output.object();
// output.key("add").value(canWriteLog);
// output.key("remove").value(canWriteLog);
output.endObject();

%>