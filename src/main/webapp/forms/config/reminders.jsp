<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>
<%
JSONWriter output = new JSONWriter(out);

output.object();

boolean canWrite = Permissions.canWrite(session, "config_lembretes");

output.key("permissions").object();
output.key("add").value(canWrite);
output.key("remove").value(canWrite);
output.endObject();

output.endObject();

%>