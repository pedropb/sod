<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
JSONWriter output = new JSONWriter(out);

boolean canWriteActivities = Permissions.canWrite(session, "definitions_activities");

output.object();
output.key("add").value(canWriteActivities);
output.key("edit").value(canWriteActivities);
output.key("remove").value(canWriteActivities);
output.key("conflicts").value(canWriteActivities);

output.key("transactions").object();
output.key("add").value(canWriteActivities);
output.key("edit").value(false);
output.key("remove").value(canWriteActivities);
output.endObject();

output.endObject();

%>