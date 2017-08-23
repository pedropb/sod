<%@page import="com.sun.xml.internal.fastinfoset.util.StringArray"%>
<%@page import="com.sun.org.apache.xerces.internal.xs.StringList"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="geotech.Database"%>
<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>
<% 
if (!Permissions.canRead(session, "dashboard",  response, out))
	return;

JSONWriter output = new JSONWriter(out);

Database db = new Database();

String sql = 	"SELECT\n"+
				"	snapshot_id AS id,\n" +
				"	to_char(created, 'DD/MM/YYYY') AS date,\n" +
				"	users_conflicts,\n" +
				"	accepted_users_conflicts,\n" +
				"	groups_conflicts,\n" +
				"	accepted_groups_conflicts\n" +
				"FROM snapshots\n" +
				"ORDER BY snapshot_id";
ResultSet result = db.query(sql);

output.object();
output.key("data").array();

while (result.next()) {
	output.object();
	output.key("id").value(result.getInt("id"));
	output.key("date").value(result.getString("date"));
	output.key("usersConflicts").value(result.getInt("users_conflicts"));
	output.key("usersResiduals").value(result.getInt("accepted_users_conflicts"));
	output.key("groupsConflicts").value(result.getInt("groups_conflicts"));
	output.key("groupsResiduals").value(result.getInt("accepted_groups_conflicts"));
	output.endObject();
}

output.endArray();
output.endObject();

%>