<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
if (!Permissions.canWrite(session, "tools_create_groups", response, out)) {
	return;
}

JSONWriter output = new JSONWriter(out);

boolean canReadGroups = Permissions.canRead(session, "definitions_groups");
boolean canWriteGroups = Permissions.canWrite(session, "definitions_groups");

output.object();
if (canReadGroups) {
	output.key("transactions").object();
	output.key("add").value(canWriteGroups);
	output.key("edit").value(false);
	output.key("remove").value(canWriteGroups);
	output.endObject();

	output.key("users").object();
	output.key("add").value(canWriteGroups);
	output.key("edit").value(false);
	output.key("remove").value(canWriteGroups);
	output.endObject();
}

output.endObject();

%>