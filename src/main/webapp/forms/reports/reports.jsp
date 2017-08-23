<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>
<% 
JSONWriter output = new JSONWriter(out);

output.object();
output.key("panelMenu").array();

if (Permissions.canRead(session, "reports_summary")) {
	output.object();
	output.key("text").value("Resumo");
	output.key("formId").value("summaryReport");
	output.endObject();
}

if (Permissions.canRead(session, "reports_users")) {
	output.object();
	output.key("text").value("Distrib. de Usuários");
	output.key("formId").value("usersReport");
	output.endObject();
}

if (Permissions.canRead(session, "reports_groups")) {
	output.object();
	output.key("text").value("Distrib. de Grupos");
	output.key("formId").value("groupsReport");
	output.endObject();
}

if (Permissions.canRead(session, "reports_transactions")) {
	output.object();
	output.key("text").value("Distrib. de Transações");
	output.key("formId").value("transactionsReport");
	output.endObject();
}

if (Permissions.canRead(session, "reports_activities")) {
	output.object();
	output.key("text").value("Distrib. de Atividades");
	output.key("formId").value("activitiesReport");
	output.endObject();
}

if (Permissions.canRead(session, "reports_modules")) {
	output.object();
	output.key("text").value("Distrib. de Módulos");
	output.key("formId").value("modulesReport");
	output.endObject();
}

if (Permissions.canRead(session, "reports_conflicts")) {
	output.object();
	output.key("text").value("Distrib. de Conflitos");
	output.key("formId").value("conflictsReport");
	output.endObject();
}

if (Permissions.canRead(session, "reports_users_solutions")) {
	output.object();
	output.key("text").value("Distrib. de Aceites Usuários");
	output.key("formId").value("usersSolutionsReport");
	output.endObject();
}

if (Permissions.canRead(session, "reports_users_solutions_general")) {
	output.object();
	output.key("text").value("Relatório de Aceites Usuários");
	output.key("formId").value("usersSolutionsGeneralReport");
	output.endObject();
}

if (Permissions.canRead(session, "reports_groups_solutions")) {
	output.object();
	output.key("text").value("Distrib. de Aceites Grupos");
	output.key("formId").value("groupsSolutionsReport");
	output.endObject();
}

if (Permissions.canRead(session, "reports_groups_solutions_general")) {
	output.object();
	output.key("text").value("Relatório de Aceites Grupos");
	output.key("formId").value("groupsSolutionsGeneralReport");
	output.endObject();
}

output.endArray();
output.endObject();

%>