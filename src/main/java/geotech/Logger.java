/*
 * Copyright 2012 by Pedro Baracho
 * pedropbaracho@gmail.com
 */

package geotech;

import javax.servlet.http.HttpSession;

import org.apache.commons.lang.StringEscapeUtils;

/* 
 * Implements PostgreSQL database manipulation methods.
 */
public class Logger
{
	private Database db;
	private String userId;
	
	public Logger(HttpSession session)
	{
		db = Database.createDatabase();
		if (session.getAttribute("userId") instanceof Integer)
			userId = (Integer) session.getAttribute("userId") + "";
		else if (session.getAttribute("userId") instanceof String)
			userId = (String) session.getAttribute("userId");
	}
	
	public boolean log(String description, String module, String form)
	{
		return log(description, module, form, "");
	}
	
	public boolean log(String description, String module, String form, String operation)
	{
		String sql;
		
		sql = 	"INSERT INTO log(gt_user_id, operation, module, description, form)\n" +
				"VALUES (	" + StringEscapeUtils.escapeSql(userId) + ",\n" +
							"'" + StringEscapeUtils.escapeSql(operation) + "',\n" +
							"'" + StringEscapeUtils.escapeSql(module) + "',\n" +
							"'" + StringEscapeUtils.escapeSql(description) + "',\n" +
							"'" + StringEscapeUtils.escapeSql(form) + "')";
		
		return db.update(sql) > 0;
	}
}
