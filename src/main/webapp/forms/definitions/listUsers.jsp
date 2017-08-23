<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
JSONWriter output = new JSONWriter(out);

boolean canWriteUsers = Permissions.canWrite(session, "definitions_users");

output.object();
output.key("add").value(canWriteUsers);
output.key("edit").value(canWriteUsers);
output.key("remove").value(canWriteUsers);

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

output.endObject();

%>