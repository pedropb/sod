<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
JSONWriter output = new JSONWriter(out);

boolean canWriteTransactions = Permissions.canWrite(session, "definitions_transactions");

output.object();
output.key("add").value(canWriteTransactions);
output.key("edit").value(canWriteTransactions);
output.key("remove").value(canWriteTransactions);
output.endObject();

%>