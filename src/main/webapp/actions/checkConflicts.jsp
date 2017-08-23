<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="java.util.Iterator"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="geotech.Permissions"%>
<%@page import="java.util.List"%>
<%@page import="java.util.SortedMap"%>
<%@page import="org.json.JSONWriter"%>
<%@page import="alttus.ConflictChecker"%>
<%
String action = request.getParameter("action");

JSONWriter output = new JSONWriter(out);

if (action == null) {
	response.setStatus(400);

	output.object();
	output.key("success").value(false);
	output.key("message").value("Action é obrigatório");
	output.endObject();

	return;
}

if (action.equals("conflictsBetweenNewTransactionsAndUser")
		&& request.getParameter("user") != null
		&& request.getParameter("transactions") != null)
{
	if (!Permissions.canWrite(session, "definitions_users", response, out))
		return;
	
	try {
		String transactions = request.getParameter("transactions");
		String user = request.getParameter("user");
		
		List<String> transactionConflicts = ConflictChecker.conflictsBetweenTransactions(transactions);
		List<String> userNewConflicts = ConflictChecker.conflictsBetweenNewTransactionsAndUser(transactions, user);
		int conflictCount = transactionConflicts.size() + userNewConflicts.size();

		String resultDetails = "";
		if (transactionConflicts.size() > 0) {
			resultDetails += transactionConflicts.size() + " conflitos entre as transações selecionadas:\n" + StringUtils.join((List<String>) transactionConflicts, "\n");
			resultDetails += "\n\n";
		}
		if (userNewConflicts.size() > 0) {
			resultDetails += userNewConflicts.size() + " NOVOS conflitos para o usuário "+ user +" :\n" + StringUtils.join((List<String>) userNewConflicts, "\n");
		}

		output.object();
		output.key("success").value(true);
		output.key("conflicts").value(conflictCount);
		output.key("details").value(resultDetails);
		output.endObject();
	}
	catch (Exception ex) {
		output.object();
		output.key("success").value(false);
		output.key("message").value(ex.getLocalizedMessage());
		output.endObject();
	}
}
else if (action.equals("conflictsBetweenNewTransactionsAndGroup")
		&& request.getParameter("group") != null
		&& request.getParameter("transactions") != null)
{
	if (!Permissions.canWrite(session, "definitions_groups", response, out))
		return;
	
	try {
		String transactions = request.getParameter("transactions");
		String group = request.getParameter("group");

		List<String> transactionConflicts = ConflictChecker.conflictsBetweenTransactions(transactions);
		SortedMap<String, List<String>> groupNewConflicts = ConflictChecker.conflictsBetweenNewTransactionsAndGroup(transactions, group);
		
		String resultDetails = "";
		int conflictCount = transactionConflicts.size();
		if (transactionConflicts.size() > 0) {
			resultDetails += transactionConflicts.size() + " conflitos entre as transações selecionadas:\n" + StringUtils.join((List<String>) transactionConflicts, "\n");
			resultDetails += "\n\n";
		}
		
		Iterator<SortedMap.Entry<String,List<String>>> it = groupNewConflicts.entrySet().iterator();
	    while (it.hasNext()) {
	        SortedMap.Entry<String,List<String>> pair = (SortedMap.Entry<String,List<String>>)it.next();

	        if (((List<String>) pair.getValue()).size() > 0) {
	        	resultDetails += ((List<String>) pair.getValue()).size() + " NOVOS conflitos para o " + pair.getKey() + " :\n" + StringUtils.join((List<String>) pair.getValue(), "\n");
				resultDetails += "\n\n";
				conflictCount += ((List<String>) pair.getValue()).size();
	        }
	    }

		output.object();
		output.key("success").value(true);
		output.key("conflicts").value(conflictCount);
		output.key("details").value(resultDetails);
		output.endObject();	
	}
	catch (Exception ex) {
		output.object();
		output.key("success").value(false);
		output.key("message").value(ex.getLocalizedMessage());
		output.endObject();
	}
}
else if (action.equals("conflictsBetweenNewUsersAndGroup")
		&& request.getParameter("group") != null
		&& request.getParameter("users") != null)
{
	if (!Permissions.canWrite(session, "definitions_groups", response, out))
		return;
	
	try {
		String users = request.getParameter("users");
		String group = request.getParameter("group");

		SortedMap<String, List<String>> groupNewConflicts = ConflictChecker.conflictsBetweenNewUsersAndGroup(users, group);
		
		String resultDetails = "";
		int conflictCount = 0;
		
		Iterator<SortedMap.Entry<String,List<String>>> it = groupNewConflicts.entrySet().iterator();
	    while (it.hasNext()) {
	        SortedMap.Entry<String,List<String>> pair = (SortedMap.Entry<String,List<String>>)it.next();

	        if (((List<String>) pair.getValue()).size() > 0) {
	        	resultDetails += ((List<String>) pair.getValue()).size() + " NOVOS conflitos para o " + pair.getKey() + " :\n" + StringUtils.join((List<String>) pair.getValue(), "\n");
				resultDetails += "\n\n";
				conflictCount += ((List<String>) pair.getValue()).size();
	        }
	    }

		output.object();
		output.key("success").value(true);
		output.key("conflicts").value(conflictCount);
		output.key("details").value(resultDetails);
		output.endObject();	
	}
	catch (Exception ex) {
		output.object();
		output.key("success").value(false);
		output.key("message").value(ex.getLocalizedMessage());
		output.endObject();
	}
}
else {
	response.setStatus(400);

	output.object();
	output.key("success").value(false);
	output.key("message").value("Parâmetros incorretos");
	output.endObject();
}
%>
