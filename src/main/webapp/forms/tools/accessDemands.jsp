<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
JSONWriter output = new JSONWriter(out);

if (!Permissions.canRead(session, "tools_access_demands", response, out)) {
	return;
}

boolean canWrite = Permissions.canWrite(session, "tools_access_demands");

output.object();
output.key("approve").value(canWrite);
output.endObject();

%>