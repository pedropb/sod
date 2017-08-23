<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>
<% 
JSONWriter output = new JSONWriter(out);

output.object();
output.key("panelMenu").array();

if (Permissions.canRead(session, "tools_snapshots")) {
	output.object();
	output.key("text").value("Snapshots");
	output.key("formId").value("snapshots");
	output.endObject();
}

if (Permissions.canRead(session, "tools_solve_conflicts")) {
	output.object();
	output.key("text").value("Resolução de Conflitos");
	output.key("formId").value("solveConflicts");
	output.endObject();
}

if (Permissions.canRead(session, "tools_create_groups")) {
	output.object();
	output.key("text").value("Criar Grupos");
	output.key("formId").value("createGroups");
	output.endObject();
}

if (Permissions.canRead(session, "tools_create_users")) {
	output.object();
	output.key("text").value("Criar Usuários");
	output.key("formId").value("createUsers");
	output.endObject();
}

if (Permissions.canRead(session, "tools_changelog")) {
	output.object();
	output.key("text").value("Relatório de Alterações");
	output.key("formId").value("changeLog");
	output.endObject();
}

if (Permissions.canRead(session, "tools_verify_data")) {
	output.object();
	output.key("text").value("Consolidação dos dados");
	output.key("formId").value("verifyData");
	output.endObject();
}

if (Permissions.canRead(session, "tools_my_access_demands")) {
	output.object();
	output.key("text").value("Minhas Solicitações de Acesso");
	output.key("formId").value("myAccessDemands");
	output.endObject();
}

if (Permissions.canRead(session, "tools_access_demands")) {
	output.object();
	output.key("text").value("Solicitações de Acesso");
	output.key("formId").value("accessDemands");
	output.endObject();
}

output.endArray();
output.endObject();

%>