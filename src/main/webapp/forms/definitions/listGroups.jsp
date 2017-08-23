<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
JSONWriter output = new JSONWriter(out);

boolean canWriteGroups = Permissions.canWrite(session, "definitions_groups");

output.object();
output.key("add").value(canWriteGroups);
output.key("edit").value(canWriteGroups);
output.key("remove").value(canWriteGroups);

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

output.endObject();

%>