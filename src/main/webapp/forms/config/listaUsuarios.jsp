<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
JSONWriter output = new JSONWriter(out);

output.object();

output.key("permissions").object();
output.key("add").value(Permissions.canWrite(session, "config_usuarios"));
output.key("edit").value(Permissions.canWrite(session, "config_usuarios"));
output.key("password").value(Permissions.canWrite(session, "config_usuarios_senha"));
output.endObject();

output.endObject();

%>