<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>
<%
JSONWriter output = new JSONWriter(out);

output.object();

output.key("permissions").object();
output.key("add").value(Permissions.canWrite(session, "config_grupos_permissoes"));
output.key("edit").value(Permissions.canWrite(session, "config_grupos_permissoes"));
output.key("remove").value(Permissions.canWrite(session, "config_grupos_permissoes"));
output.endObject();

output.endObject();

%>