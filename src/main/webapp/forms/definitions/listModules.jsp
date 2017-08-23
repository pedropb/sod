<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
JSONWriter output = new JSONWriter(out);

boolean canWriteModules = Permissions.canWrite(session, "definitions_modules");

output.object();
output.key("add").value(canWriteModules);
output.key("edit").value(canWriteModules);
output.key("remove").value(canWriteModules);

output.key("transactions").object();
output.key("add").value(canWriteModules);
output.key("edit").value(false);
output.key("remove").value(canWriteModules);
output.endObject();

output.endObject();

%>