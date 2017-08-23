<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
JSONWriter output = new JSONWriter(out);

boolean canWriteConflicts = Permissions.canWrite(session, "definitions_conflicts");

output.object();
output.key("add").value(canWriteConflicts);
output.key("edit").value(canWriteConflicts);
output.key("remove").value(canWriteConflicts);
output.endObject();

%>