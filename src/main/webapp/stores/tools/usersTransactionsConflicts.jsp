<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "tools_solve_conflicts", response, out)) {
	return;
}

String userId = request.getParameter("user_id");
String conflictId = request.getParameter("conflict_id");
String activityNo = request.getParameter("activity");

if (userId == null || conflictId == null || activityNo == null) {
	Permissions.outputError(response, out);
	return;
}

// AQUI DEVE SELECIONAR SOMENTE AS TRANSAÇÕES DOS USUÁRIOS
// AS TRANSAÇÕES DOS GRUPOS SERÃO SELECIONADAS EM groupsTransactionsConflicts
sql = 	"SELECT\n" +
		"	t.transaction_id AS id,\n" + 
		"	t.name\n" +
		"FROM\n" +
		"	transactions t\n" +
		"	INNER JOIN users_transactions ut ON ut.transaction_id = t.transaction_id\n" +
		"WHERE\n" +
		"	t.activity_id = (SELECT activity"+ activityNo +" FROM conflicts WHERE conflict_id = '"+ StringEscapeUtils.escapeSql(conflictId) + "')\n" +
		"	AND ut.user_id = '" + StringEscapeUtils.escapeSql(userId) + "'\n" +
		"ORDER BY id";

ExtStore.generateStore(sql, request, out);
%>