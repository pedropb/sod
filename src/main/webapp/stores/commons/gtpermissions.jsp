<%@page import="geotech.Database"%>
<%@page contentType="application/json" %>
<%@page pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="java.sql.Array"%>
[
<%
	String userId = request.getParameter("userId");
	String groupId = request.getParameter("groupId");
	
	Database db = Database.createDatabase();
	
	if (userId != null && !userId.isEmpty()){
		String sql;
		
		if (groupId != null && !groupId.isEmpty()) 
			sql = 	"SELECT\n" +
					"	pg.permission_group, p.id, p.permission, p.reference, p.read_write, up.value, gp.value AS group_value\n" +
					"FROM\n" +
					"	gt_permissions p\n" +
					"		LEFT JOIN gt_permission_groups pg ON p.group_id = pg.id\n" +
					"		LEFT JOIN (SELECT * FROM gt_users_permissions WHERE user_id = " + userId + ") up ON p.id = up.permission\n" +
					"		LEFT JOIN (SELECT * FROM gt_groups_permissions WHERE group_id = " + groupId + ") gp ON p.id = gp.permission\n" +
					"ORDER BY pg.permission_group, p.permission";
		else
			sql = 	"SELECT\n" +
					"	pg.permission_group, p.id, p.permission, p.reference, p.read_write, up.value, gp.value AS group_value\n" +
					"FROM\n" +
					"	gt_permissions p\n" +
					"		LEFT JOIN gt_permission_groups pg ON p.group_id = pg.id\n" +
					"		LEFT JOIN (SELECT * FROM gt_users_permissions WHERE user_id = " + userId + ") up ON p.id = up.permission\n" +
					"		LEFT JOIN (SELECT * FROM gt_groups_permissions WHERE group_id IN\n" +
					"			(SELECT group_id FROM users_groups WHERE user_id = " + userId + ")) gp ON p.id = gp.permission\n" +
					"ORDER BY pg.permission_group, p.permission";
		
		ResultSet result = db.query(sql);
		
		String group = "";
		int groupNum = 0;
		int permissionNum = 0;
		while (result.next()) {
			if (!group.equals(result.getString("permission_group"))){
				if (groupNum++ != 0) out.println("]}, ");
				
				group = result.getString("permission_group");
				
				out.println("{\n" +
						"group: '" + StringEscapeUtils.escapeJavaScript(group) + "',\n" +
						"permissions: [");
				
				permissionNum = 0;
			}
			
			out.println((permissionNum++ != 0 ? ", " : "") + "{\n" +
					"id: " + result.getString("id") + ",\n" +
					"permission: '" + StringEscapeUtils.escapeJavaScript(result.getString("permission")) + "',\n" +
					"reference: '" + StringEscapeUtils.escapeJavaScript(result.getString("reference")) + "',\n" +
					"readWrite: " + result.getBoolean("read_write") + ",\n" +
					"value: " + result.getString("value") + ",\n" +
					"groupValue: " + result.getString("group_value") + "\n" +
					"}");
		}
		
		if (groupNum > 0) out.println("]}");
		
	} else if (groupId != null && !groupId.isEmpty()){			
		String sql = 	"SELECT\n" +
						"	pg.permission_group, p.id, p.permission, p.reference, p.read_write, gp.value\n" +
						"FROM\n" +
						"	gt_permissions p\n" +
	    				"		LEFT JOIN gt_permission_groups pg ON p.group_id = pg.id\n" +
	    				"		LEFT JOIN (SELECT * FROM gt_groups_permissions WHERE group_id = " + groupId + ") gp ON p.id = gp.permission\n" +
	    				"ORDER BY pg.permission_group, p.permission";

		ResultSet result = db.query(sql);
		
		String group = "";
		int groupNum = 0;
		int permissionNum = 0;
		while (result.next()) {
			if (!group.equals(result.getString("permission_group"))){
				if (groupNum++ != 0) out.println("]}, ");
				
				group = result.getString("permission_group");
				
				out.println("{\n" +
						"group: '" + StringEscapeUtils.escapeJavaScript(group) + "',\n" +
						"permissions: [");
				
				permissionNum = 0;
			}
			
			out.println((permissionNum++ != 0 ? ", " : "") + "{\n" +
					"id: " + result.getString("id") + ",\n" +
					"permission: '" + StringEscapeUtils.escapeJavaScript(result.getString("permission")) + "',\n" +
					"reference: '" + StringEscapeUtils.escapeJavaScript(result.getString("reference")) + "',\n" +
					"readWrite: " + result.getBoolean("read_write") + ",\n" +
					"value: " + result.getString("value") + "\n" +
					"}");
		}
		
		if (groupNum > 0) out.println("]}");
	}
	
	db.close();
%>
]