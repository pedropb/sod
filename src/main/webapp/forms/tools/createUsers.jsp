<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
if (!Permissions.canWrite(session, "tools_create_users", response, out)) {
	return;
}

JSONWriter output = new JSONWriter(out);

boolean canReadUsers = Permissions.canRead(session, "definitions_users");
boolean canWriteUsers = Permissions.canWrite(session, "definitions_users");

output.object();

if (canReadUsers) {
	output.key("transactions").object();
	output.key("add").value(canWriteUsers);
	output.key("edit").value(false);
	output.key("remove").value(canWriteUsers);
	output.endObject();

	output.key("groups").object();
	output.key("add").value(canWriteUsers);
	output.key("edit").value(false);
	output.key("remove").value(canWriteUsers);
	output.endObject();
}

output.endObject();

%>