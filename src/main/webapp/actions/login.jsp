<%@page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@page import="geotech.Database"%>
<%@page import="alttus.ADAuth"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.io.IOException"%>
<%@page import="java.sql.SQLException"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils" %>

<%!
public ResultSet authenticateUserAgainstDb(Database db, String username, String password) {
	String sql = 	"SELECT\n" +
					"	id,\n" +
					"	active \n" +
					"FROM\n" +
					"	gt_users\n" +
					"WHERE\n" +
					"	LOWER(login) = LOWER('" + StringEscapeUtils.escapeSql(username) + "')\n" +
					"	AND password = MD5('" + StringEscapeUtils.escapeSql(password) + "')\n" +
					"	AND initialized = TRUE";

	return db.query(sql);
}


public ResultSet fetchUser(Database db, String username) {
	String sql = 	"SELECT\n" +
					"	id,\n" +
					"	active \n" +
					"FROM\n" +
					"	gt_users\n" +
					"WHERE\n" +
					"	LOWER(login) = LOWER('" + StringEscapeUtils.escapeSql(username) + "')\n" +
					"	AND initialized = TRUE";

	return db.query(sql);
}

public void startSession(JspWriter out, HttpSession session, ResultSet result) throws SQLException, IOException {
	String id = result.getString("id");
	boolean active = result.getBoolean("active");
	
	if (active) {
		session.setAttribute("userId", id);
		
		out.println("{success: true}");
	}
	else {
		out.println("{success: false, msg: 'Usuário desativado.'}");
	}
}
%>
<%
final String AD_GROUP_NAME = "AD Users";
String action = request.getParameter("action");
action = action == null ? "" : action;

if(action.equals("login")) {
	ADAuth auth = ADAuth.createADAuth();
	
	String username = request.getParameter("username");
	String password = request.getParameter("password");

	Database db =  Database.createDatabase();
	ResultSet result;
	
	// check user credentials against Database
	result = authenticateUserAgainstDb(db, username, password);
	if (result.next()) {
		startSession(out, session, result);
		db.close();
		return;
	}

	boolean validLogin = false;
	try {
		// authenticate against Active Directory
		validLogin = auth.isValidLogin(username, password);
	}
	catch (Exception ex) {
		// This throws if Active Directory is not accessible or can't authenticate with master user.
		// (i.e: configuration problems - see web.xml)
		out.println("{success: false, msg: 'Não foi possível autenticar com o Active Directory.'}");
		db.close();
		return;
	}

	if (!validLogin) {
		// Login is invalid if credentials cannot be found or do not match Active Directory.
		out.println("{success: false, msg: 'Login / Senha incorretos(s). Verificar credenciais no LDAP.'}");
		db.close();
		return;
	}

	// with a valid login:
	result = fetchUser(db, username);
	
	// check if user exists on Database and load its id on the session
	if(result.next()){
		startSession(out, session, result);
	}
	else {
		// if user does not exist, insert new user on Database with default group 
		// permissions and then load its id on session.

		String sql = 	"INSERT INTO gt_users(login, initialized)\n"+
						" VALUES ('" + StringEscapeUtils.escapeSql(username) + "', true)";

		if (db.update(sql) != 1) {
			// some problem occured
			out.println("{success: false, msg: 'Erro ao criar usuário no Painel.'}");
			db.close();
			return;
		}

		// after inserting user insert user on default group
		sql = 	"INSERT INTO gt_users_groups \n" +
				"SELECT u.id, g.id \n" +
				"FROM gt_users u, gt_user_groups g \n" +
				"WHERE lower(u.login) = lower('" + StringEscapeUtils.escapeSql(username) + "') and g.user_group = '" + AD_GROUP_NAME + "';";
		
		if (db.update(sql) == 1) {
			// after insert, fetch user to store user_id on session.
			result = fetchUser(db, username);
			result.next();
			startSession(out, session, result);
		}
		else {
			// some problem occured
			out.println("{success: false, msg: 'Erro ao associar usuário ao grupo do AD no Painel.'}");
		}
	}
	
	db.close();
}
else if(action.equals("logout")){
	session.removeAttribute("userId");
	
	String message = request.getParameter("message");
	if (message != null)
		session.setAttribute("message", request.getParameter("message"));
	
	response.sendRedirect("../index.jsp");
}
%>