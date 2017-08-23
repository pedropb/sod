package geotech;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspWriter;

import org.json.JSONException;
import org.json.JSONWriter;

import org.apache.commons.lang.StringEscapeUtils;

public class Permissions {

	public static int ENABLED = 2;
	public static int READ    = 1;
	public static int WRITE   = 2;
	
	public static boolean canRead(String userId, String reference){
		return getPermission(userId, reference) > 0;
	}
	
	public static boolean canRead(HttpSession session, String reference){
		String userId;
		if (session.getAttribute("userId") instanceof Integer)
			userId = (Integer) session.getAttribute("userId") + "";
		else if (session.getAttribute("userId") instanceof String)
			userId = (String) session.getAttribute("userId");
		else
			return false;
		
		return getPermission(userId, reference) > 0;
	}
	
	public static boolean canReadGroup(HttpSession session, int group){
		String userId;
		if (session.getAttribute("userId") instanceof Integer)
			userId = (Integer) session.getAttribute("userId") + "";
		else if (session.getAttribute("userId") instanceof String)
			userId = (String) session.getAttribute("userId");
		else
			return false;
		
		Database db = new Database();
		ResultSet result;
		
		if (userId.equals("0")){
			db.close();
			return true;
		}
		
		String sql =
				"SELECT\n" +
				"    CASE WHEN GREATEST(MAX(up.value), MAX(gp.value)) IS NULL THEN '0' ELSE GREATEST(MAX(up.value), MAX(gp.value)) END AS value\n" +
				"FROM\n" +
				"	gt_permissions p\n" +
				"		LEFT JOIN gt_permission_groups pg ON p.group_id = pg.id\n" +
				"		LEFT JOIN (SELECT * FROM gt_users_permissions WHERE user_id = " + userId + ") up ON p.id = up.permission\n" +
				"		LEFT JOIN (SELECT * FROM gt_groups_permissions WHERE group_id IN\n" +
				"			(SELECT group_id FROM gt_users_groups WHERE user_id = " + userId + ")) gp ON p.id = gp.permission\n" +
				"WHERE\n" +
				"	p.group_id = " + group;
		
		result = db.query(sql);
		try {
			if (result.next()) {
				int value = result.getInt("value");
				db.close();
				return value > 0;
			}	
			else {
				db.close();
				return false;
			}
				
		} catch (SQLException e) {
			db.close();
			return false;
		}
	}
	
	public static boolean canRead(HttpSession session, String reference, HttpServletResponse response, JspWriter out) throws JSONException{
		String userId;
		if (session.getAttribute("userId") instanceof Integer)
			userId = (Integer) session.getAttribute("userId") + "";
		else if (session.getAttribute("userId") instanceof String)
			userId = (String) session.getAttribute("userId");
		else
			return false;
		
		boolean authorized = getPermission(userId, reference) > 0;
		
		if (!authorized) {
			outputError(response, out);
		}
			
		return authorized;
	}
	
	public static boolean canRead(HttpSession session, String [] references, HttpServletResponse response, JspWriter out) throws JSONException{
		String userId;
		if (session.getAttribute("userId") instanceof Integer)
			userId = (Integer) session.getAttribute("userId") + "";
		else if (session.getAttribute("userId") instanceof String)
			userId = (String) session.getAttribute("userId");
		else
			return false;
		
		boolean authorized = false; 
		
		for (int i = 0; i < references.length; i++)
			if (getPermission(userId, references[i]) > 0) {
				authorized = true;
				break;
			}
		
		if (!authorized) {
			outputError(response, out);
		}
			
		return authorized;
	}
	
	public static boolean canWrite(String userId, String reference){
		return getPermission(userId, reference) == 2;
	}
	
	public static boolean canWrite(HttpSession session, String reference){
		String userId;
		if (session.getAttribute("userId") instanceof Integer)
			userId = (Integer) session.getAttribute("userId") + "";
		else if (session.getAttribute("userId") instanceof String)
			userId = (String) session.getAttribute("userId");
		else
			return false;
		
		return getPermission(userId, reference) == 2;
	}
	
	public static boolean canWrite(HttpSession session, String [] references) throws JSONException{
		String userId;
		if (session.getAttribute("userId") instanceof Integer)
			userId = (Integer) session.getAttribute("userId") + "";
		else if (session.getAttribute("userId") instanceof String)
			userId = (String) session.getAttribute("userId");
		else
			return false;
		
		boolean authorized = false; 
		
		for (int i = 0; i < references.length; i++)
			if (getPermission(userId, references[i]) == 2) {
				authorized = true;
				break;
			}
			
		return authorized;
	}
	
	public static boolean canWrite(HttpSession session, String reference, HttpServletResponse response, JspWriter out) throws JSONException{
		String userId;
		if (session.getAttribute("userId") instanceof Integer)
			userId = (Integer) session.getAttribute("userId") + "";
		else if (session.getAttribute("userId") instanceof String)
			userId = (String) session.getAttribute("userId");
		else
			return false;
		
		boolean authorized = getPermission(userId, reference) == 2;
		
		if (!authorized) {
			outputError(response, out);
		}
			
		return authorized;
	}
	
	public static boolean canWrite(HttpSession session, String [] references, HttpServletResponse response, JspWriter out) throws JSONException{
		String userId;
		if (session.getAttribute("userId") instanceof Integer)
			userId = (Integer) session.getAttribute("userId") + "";
		else if (session.getAttribute("userId") instanceof String)
			userId = (String) session.getAttribute("userId");
		else
			return false;
		
		boolean authorized = false; 
		
		for (int i = 0; i < references.length; i++)
			if (getPermission(userId, references[i]) == 2) {
				authorized = true;
				break;
			}
		
		if (!authorized) {
		 	outputError(response, out);
		}
			
		return authorized;
	}

	public static int getPermission(int userId, String reference) {
		return getPermission(userId + "", reference);
	}
	
	public static int getPermission(String userId, String reference) {
		Database db = new Database();
		ResultSet result;
		
		if (userId.equals("0")){
			db.close();
			return 2;
		}
		
		String sql =
				"SELECT\n" +
				"    CASE WHEN GREATEST(MAX(up.value), MAX(gp.value)) IS NULL THEN '0' ELSE GREATEST(MAX(up.value), MAX(gp.value)) END AS value\n" +
				"FROM\n" +
				"	gt_permissions p\n" +
				"		LEFT JOIN gt_permission_groups pg ON p.group_id = pg.id\n" +
				"		LEFT JOIN (SELECT * FROM gt_users_permissions WHERE user_id = " + userId + ") up ON p.id = up.permission\n" +
				"		LEFT JOIN (SELECT * FROM gt_groups_permissions WHERE group_id IN\n" +
				"			(SELECT group_id FROM gt_users_groups WHERE user_id = " + userId + ")) gp ON p.id = gp.permission\n" +
				"WHERE\n" +
				"	p.reference = '" + StringEscapeUtils.escapeSql(reference) + "'";
		
		result = db.query(sql);
		try {
			if (result.next()) {
				int value = result.getInt("value");
				db.close();
				return value;
			}	
			else {
				db.close();
				return 0;
			}
				
		} catch (SQLException e) {
			db.close();
			return 0;
		}
	}
	
	public static void outputError(HttpServletResponse response, JspWriter out) throws JSONException {
		JSONWriter output = new JSONWriter(out);
		
		response.setStatus(401);
		
	 	output.object();
	 	output.key("success").value(false);
	 	output.key("message").value("Acesso não autorizado");
	 	output.endObject();
	}
	
	public static void updateUserPermissions(HttpServletRequest request, String userId, String groupId) throws SQLException {
		Database db = new Database();
		ResultSet result;
		
		String sql = "DELETE FROM gt_users_groups WHERE user_id = " + userId;		
		db.update(sql);

	   	if (groupId != null && !groupId.equals("-1")) {
			sql = "INSERT INTO gt_users_groups (user_id, group_id) VALUES(" + userId + ", " + groupId + ")";		
			db.update(sql);
	   	}

		sql = "DELETE FROM gt_users_permissions WHERE user_id = " + userId;		
		db.update(sql);
	   	
	   	Enumeration<String> en = (Enumeration<String>) request.getParameterNames();
		while (en.hasMoreElements()) {
			String paramName = (String) en.nextElement();
			
			if (paramName.contains("permission@*@"))
			{
				if (paramName.contains("@*@enabled"))
				{
					sql = "INSERT INTO gt_users_permissions (user_id, permission, value) " +
						"VALUES (" + userId + ", " + 
								paramName.replace("permission@*@", "").replace("@*@enabled", "") + ", 2)";

					db.update(sql);
				}
				else if (paramName.contains("@*@read"))
				{
					String permissionId = paramName.replace("permission@*@", "").replace("@*@read", "");
					
					sql = "SELECT value FROM gt_users_permissions WHERE user_id = " + userId + " AND permission = " + permissionId;
					result = db.query(sql);
					if (result.next())
					{
						if (result.getInt("value") == 2)
							continue;
						else
						{
							sql = "DELETE FROM gt_users_permissions WHERE user_id = " + userId + " AND permission = " + permissionId; 
							db.update(sql);
						}
					}

					sql = "INSERT INTO gt_users_permissions (user_id, permission, value) " +
						"VALUES (" + userId + ", " + permissionId + ", 1)";
					db.update(sql);
				}
				else if (paramName.contains("@*@write"))
				{
					String permissionId = paramName.replace("permission@*@", "").replace("@*@write", "");
					
					sql = "DELETE FROM gt_users_permissions WHERE user_id = " + userId + " AND permission = " + permissionId; 
					db.update(sql);
					
					sql = "INSERT INTO gt_users_permissions (user_id, permission, value) " +
					"VALUES (" + userId + ", " + permissionId + ", 2)";
					db.update(sql);
				}
			}
		}
	}
	
	public static void updateGroupPermissions(HttpServletRequest request, String groupId) throws SQLException {
		Database db = new Database();
		ResultSet result;
		
		String sql = "DELETE FROM gt_groups_permissions WHERE group_id = " + groupId;		
	   	db.update(sql);
	   	
	   	Enumeration<String> en = (Enumeration<String>) request.getParameterNames();
		while (en.hasMoreElements()) {
			String paramName = (String) en.nextElement();
			
			if (paramName.contains("permission@*@"))
			{
				if (paramName.contains("@*@enabled"))
				{
					sql = "INSERT INTO gt_groups_permissions (group_id, permission, value) " +
						"VALUES (" + groupId + ", " + 
								paramName.replace("permission@*@", "").replace("@*@enabled", "") + ", 2)";

					db.update(sql);
				}
				else if (paramName.contains("@*@read"))
				{
					String permissionId = paramName.replace("permission@*@", "").replace("@*@read", "");
					
					sql = "SELECT value FROM gt_groups_permissions WHERE group_id = " + groupId + " AND permission = " + permissionId;
					result = db.query(sql);
					if (result.next())
					{
						if (result.getInt("value") == 2)
							continue;
						else
						{
							sql = "DELETE FROM gt_groups_permissions WHERE group_id = " + groupId + " AND permission = " + permissionId; 
							db.update(sql);
						}
					}

					sql = "INSERT INTO gt_groups_permissions (group_id, permission, value) " +
						"VALUES (" + groupId + ", " + permissionId + ", 1)";
					db.update(sql);
				}
				else if (paramName.contains("@*@write"))
				{
					String permissionId = paramName.replace("permission@*@", "").replace("@*@write", "");
					
					sql = "DELETE FROM gt_groups_permissions WHERE group_id = " + groupId + " AND permission = " + permissionId; 
					db.update(sql);
					
					sql = "INSERT INTO gt_groups_permissions (group_id, permission, value) " +
					"VALUES (" + groupId + ", " + permissionId + ", 2)";
				db.update(sql);
				}
			}
		}
	}
}