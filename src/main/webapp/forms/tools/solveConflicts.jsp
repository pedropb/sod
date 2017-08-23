<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
JSONWriter output = new JSONWriter(out);

boolean canSolve = Permissions.canWrite(session, "tools_solve_conflicts");

output.object();
output.key("solve").value(canSolve);
output.endObject();

%>