<%@page import="org.apache.poi.ss.usermodel.Sheet"%>
<%@page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@page import="org.apache.poi.ss.usermodel.Workbook"%>
<%@page import="org.apache.poi.ss.usermodel.WorkbookFactory"%>
<%@page import="org.eclipse.jdt.internal.compiler.ast.ForeachStatement"%>
<%@page import="org.apache.jasper.tagplugins.jstl.core.ForEach"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="geotech.Logger"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="geotech.upload.ItemUpload"%>
<%@page import="java.util.Map"%>
<%@page import="geotech.upload.Receptor"%>
<%@page import="geotech.Permissions"%>
<%@page import="org.json.JSONWriter"%>
<%@page import="geotech.Database"%>
<%@page import="java.util.Locale"%>
<%@page import="geotech.Utils"%>
<%@page import="geotech.sod.DataVerifyDefinition"%>
<%@page import="java.io.File"%>
<%
if (!Permissions.canWrite(session, "tools_verify_data", response, out))
	return;

JSONWriter output = new JSONWriter(out);

try {
	// load file
	Map<String, ItemUpload> uploadData = Receptor.upload(request);
	if (uploadData == null || uploadData.get("import_file") == null) {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Nenhum arquivo foi carregado.");
		output.endObject();
	}
	else {
		File file = new File(uploadData.get("import_file").getValue());
		Workbook workbook = WorkbookFactory.create(file);
			
		
		boolean checkUsers = uploadData.get("users") != null ? uploadData.get("users").getValue().equals("on") : false;
		boolean checkGroups = uploadData.get("groups") != null ? uploadData.get("groups").getValue().equals("on") : false;
		boolean checkModules = uploadData.get("modules") != null ? uploadData.get("modules").getValue().equals("on") : false;
		boolean checkTransactions = uploadData.get("transactions") != null ? uploadData.get("transactions").getValue().equals("on") : false;
		boolean checkActivities = uploadData.get("activities") != null ? uploadData.get("activities").getValue().equals("on") : false;
		boolean checkConflicts = uploadData.get("conflicts") != null ? uploadData.get("conflicts").getValue().equals("on") : false;
		
		String result = "";
		String[] columns;
		String[] primaryKeys;
		List<String[]> differences = new ArrayList<String[]>();
		List<String[]> errors = new ArrayList<String[]>();
		boolean success = true;
		
		for (int j = 0; j < workbook.getNumberOfSheets(); j++) {
			Sheet sheet = workbook.getSheetAt(j);
			
			if (sheet.getSheetName().equals("ATIVIDADES") && checkUsers) {
				columns = new String[] {"activity_id", "name"};
				primaryKeys = new String[] {"activity_id"};
				DataVerifyDefinition data = new DataVerifyDefinition(columns, primaryKeys, "activities");
				if (!data.verifyData(sheet)) {
					errors.add(data.getErrors());
					success = false;
				}
				differences.add(data.getDifferences());
			}
			else if (sheet.getSheetName().equals("CONFLITOS") && checkUsers) {
				columns = new String[] {"conflict_id", "name", "activity1", "activity2"};
				primaryKeys = new String[] {"conflict_id"};
				DataVerifyDefinition data = new DataVerifyDefinition(columns, primaryKeys, "conflicts");
				if (!data.verifyData(sheet)) {
					errors.add(data.getErrors());
					success = false;
				}
				differences.add(data.getDifferences());
			}
			else if (sheet.getSheetName().equals("TRANSAÇÕES") && checkUsers) {
				columns = new String[] {"transaction_id", "name", "activity_id"};
				primaryKeys = new String[] {"transaction_id"};
				DataVerifyDefinition data = new DataVerifyDefinition(columns, primaryKeys, "transactions");
				if (!data.verifyData(sheet)) {
					errors.add(data.getErrors());
					success = false;
				}
				differences.add(data.getDifferences());
			}
			else if (sheet.getSheetName().equals("USUÁRIOS") && checkUsers) {
				columns = new String[] {"user_id", "name"};
				primaryKeys = new String[] {"user_id"};
				DataVerifyDefinition data = new DataVerifyDefinition(columns, primaryKeys, "users");
				if (!data.verifyData(sheet)) {
					errors.add(data.getErrors());
					success = false;
				}
				differences.add(data.getDifferences());
			}
			else if (sheet.getSheetName().equals("GRUPOS") && checkUsers) {
				columns = new String[] {"group_id", "name"};
				primaryKeys = new String[] {"group_id"};
				DataVerifyDefinition data = new DataVerifyDefinition(columns, primaryKeys, "groups");
				if (!data.verifyData(sheet)) {
					errors.add(data.getErrors());
					success = false;
				}
				differences.add(data.getDifferences());
			}
			else if (sheet.getSheetName().equals("MÓDULOS") && checkUsers) {
				columns = new String[] {"module_id", "name"};
				primaryKeys = new String[] {"module_id"};
				DataVerifyDefinition data = new DataVerifyDefinition(columns, primaryKeys, "modules");
				if (!data.verifyData(sheet)) {
					errors.add(data.getErrors());
					success = false;
				}
				differences.add(data.getDifferences());
			}
			else if (sheet.getSheetName().equals("USUÁRIO X GRUPO") && checkUsers) {
				columns = new String[] {"user_id", "group_id"};
				primaryKeys = new String[] {"user_id", "group_id"};
				DataVerifyDefinition data = new DataVerifyDefinition(columns, primaryKeys, "users_groups");
				if (!data.verifyData(sheet)) {
					errors.add(data.getErrors());
					success = false;
				}
				differences.add(data.getDifferences());
			}
			else if (sheet.getSheetName().equals("USUÁRIO X TRANSAÇÃO") && checkUsers) {
				columns = new String[] {"user_id", "transaction_id"};
				primaryKeys = new String[] {"user_id", "transaction_id"};
				DataVerifyDefinition data = new DataVerifyDefinition(columns, primaryKeys, "users_transactions");
				if (!data.verifyData(sheet)) {
					errors.add(data.getErrors());
					success = false;
				}
				differences.add(data.getDifferences());
			}
			else if (sheet.getSheetName().equals("GRUPO X TRANSAÇÃO") && checkUsers) {
				columns = new String[] {"group_id", "transaction_id"};
				primaryKeys = new String[] {"group_id", "transaction_id"};
				DataVerifyDefinition data = new DataVerifyDefinition(columns, primaryKeys, "groups_transactions");
				if (!data.verifyData(sheet)) {
					errors.add(data.getErrors());
					success = false;
				}
				differences.add(data.getDifferences());
			}
			else if (sheet.getSheetName().equals("MÓDULO X TRANSAÇÃO") && checkUsers) {
				columns = new String[] {"module_id", "transaction_id"};
				primaryKeys = new String[] {"module_id", "transaction_id"};
				DataVerifyDefinition data = new DataVerifyDefinition(columns, primaryKeys, "modules_transactions");
				if (!data.verifyData(sheet)) {
					errors.add(data.getErrors());
					success = false;
				}
				differences.add(data.getDifferences());
			}
		}
		
		String o = "";
		double initialTime = System.nanoTime();
		
		boolean correct = true;
		
		for (String[] difs : differences) {
			for (int i = 0; i < difs.length; i++) {
				o += difs[i] + "\n";
				correct = false;
			}
		}
		
		if (!correct) {
			o = "As seguintes diferenças foram encontradas:\n" + o;
		}
		else {
			o = "Nenhuma diferença foi encontrada. Os dados estão consolidados.\n";
		}
		
		o += "\n";
		
		if (!success) {
			o += "Os seguintes erros ocorreram:\n";
			
			for (String[] errs : errors) {
				for (int i = 0; i < errs.length; i++) {
					o += errs[i] + "\n";
				}
			}
			
			o += "\n";
		}
		
		o += "Consolidação finalizada " + (success ? "sem" : "com") + " erros.\n";
		double finalTime = System.nanoTime();
		o += "\nTempo decorrido: " + Math.round((finalTime - initialTime) / 1000000000) + "s";
		
		
		Logger logger = new Logger(session);
		logger.log("Consolidação de dados realizada. Resultado:\n" + o, "Ferramentas", "Consolidação de dados", "INSERT");

		output.object();
		output.key("success").value(true);
		output.key("output").value(o);
		output.endObject();
	}
}
catch (Exception ex) {
	output.object();
	output.key("success").value(false);
	output.key("message").value(ex.getMessage());
	output.endObject();
}
%>