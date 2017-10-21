<%@page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@page import="geotech.sod.DataImporter"%>
<%@page import="geotech.sod.DataImporterConfig"%>
<%@page import="geotech.Permissions"%>
<%@page import="geotech.Logger"%>
<%@page import="org.json.JSONWriter"%>
<%
if (!Permissions.canWrite(session, "definitions_import_data", response, out))
	return;

JSONWriter output = new JSONWriter(out);

try {
	DataImporterConfig cfg = DataImporterConfig.createFromRequest(request);
	String o = DataImporter.run(cfg);

	output.object();
	output.key("success").value(true);
	output.key("output").value(o);
	output.endObject();

	Logger logger = new Logger(session);
	logger.log("Importação de dados realizada. Resultado:\n" + o, "Definições", "Importação de dados", "INSERT");
}
catch (Exception ex) {
	output.object();
	output.key("success").value(false);
	output.key("message").value(ex.getMessage());
	output.endObject();
}
%>