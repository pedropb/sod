<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>
<% 
JSONWriter output = new JSONWriter(out);

output.object();
output.key("panelMenu").array();

if (Permissions.canRead(session, "definitions_users")) {
	output.object();
	output.key("text").value("Usuários");
	output.key("formId").value("listUsers");
	output.endObject();
}

if (Permissions.canRead(session, "definitions_groups")) {
	output.object();
	output.key("text").value("Grupos");
	output.key("formId").value("listGroups");
	output.endObject();
}

if (Permissions.canRead(session, "definitions_transactions")) {
	output.object();
	output.key("text").value("Transações");
	output.key("formId").value("listTransactions");
	output.endObject();
}

if (Permissions.canRead(session, "definitions_modules")) {
	output.object();
	output.key("text").value("Módulos");
	output.key("formId").value("listModules");
	output.endObject();
}

if (Permissions.canRead(session, "definitions_activities")) {
	output.object();
	output.key("text").value("Atividades");
	output.key("formId").value("listActivities");
	output.endObject();
}

if (Permissions.canRead(session, "definitions_conflicts")) {
	output.object();
	output.key("text").value("Conflitos");
	output.key("formId").value("listConflicts");
	output.endObject();
}

if (Permissions.canRead(session, "definitions_import_data")) {
	output.object();
	output.key("text").value("Importar Dados");
	output.key("formId").value("dataImport");
	output.endObject();
	output.object();
	output.key("text").value("Importar Dados FIDIS");
	output.key("formId").value("dataImportFIDIS");
	output.endObject();
}	

if (Permissions.canRead(session, "definitions_export_data")) {
	output.object();
	output.key("text").value("Exportar Dados");
	output.key("formId").value("dataExport");
	output.endObject();
}

output.endArray();
output.endObject();

%>