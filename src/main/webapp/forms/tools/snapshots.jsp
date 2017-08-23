<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>

<% 
JSONWriter output = new JSONWriter(out);

boolean canWriteSnapshots = Permissions.canWrite(session, "tools_snapshots");

output.object();
output.key("add").value(canWriteSnapshots);
output.key("remove").value(canWriteSnapshots);
output.endObject();

%>