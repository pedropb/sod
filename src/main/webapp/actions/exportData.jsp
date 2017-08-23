<%@page import="geotech.document.XlsWriter"%>
<%@page import="java.io.IOException"%>
<%@page import="geotech.document.XlsxWriter"%>
<%@page import="org.apache.poi.ss.usermodel.Cell"%>
<%@page import="org.apache.poi.ss.usermodel.Row"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFWorkbook"%>
<%@page import="org.apache.poi.ss.util.WorkbookUtil"%>
<%@page import="org.apache.poi.ss.usermodel.Sheet"%>
<%@page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@page import="geotech.Logger"%>
<%@page import="geotech.Permissions"%><%@page import="geotech.sod.DataExportDefinition"%><%@page import="jxl.write.Label"%><%@page import="jxl.write.WritableSheet"%><%@page import="java.util.Locale"%><%@page import="jxl.write.WritableWorkbook"%><%@page import="jxl.WorkbookSettings"%><%@page import="jxl.Workbook"%><%
if (!Permissions.canWrite(session, "definitions_export_data", response, out))
	return;

String extension = "";
boolean isXLS;
if (request.getParameter("format") != null && request.getParameter("format").equals("XLS")) {
	isXLS = true;
	extension = ".xls";
}
else {
	isXLS = false;
	extension = ".xlsx";
}

response.setContentType("text/html");
response.setCharacterEncoding("UTF-8");
response.addHeader("Content-Disposition","attachment; filename=\"sod_data_export" + extension + "\"");

DataExportDefinition[] data = new DataExportDefinition[10];
String[] columns;
String[] columnsName;

columns = new String[] {"activity_id", "name"};
columnsName = new String[] {"ID", "NOME"};
data[0] = new DataExportDefinition(columns, columnsName, "activities", "ATIVIDADES", "activity_id");

columns = new String[] {"conflict_id", "name", "activity1", "activity2"};
columnsName = new String[] {"ID", "NOME", "ATIVIDADE 1", "ATIVIDADE 2"};
data[1] = new DataExportDefinition(columns, columnsName, "conflicts", "CONFLITOS", "conflict_id");

columns = new String[] {"transaction_id", "name", "activity_id"};
columnsName = new String[] {"ID", "NOME", "ATIVIDADE"};
data[2] = new DataExportDefinition(columns, columnsName, "transactions", "TRANSAÇÕES", "transaction_id");

columns = new String[] {"user_id", "name"};
columnsName = new String[] {"ID", "NOME"};
data[3] = new DataExportDefinition(columns, columnsName, "users", "USUÁRIOS", "user_id");

columns = new String[] {"group_id", "name"};
columnsName = new String[] {"ID", "NOME"};
data[4] = new DataExportDefinition(columns, columnsName, "groups", "GRUPOS", "group_id");

columns = new String[] {"module_id", "name"};
columnsName = new String[] {"ID", "NOME"};
data[5] = new DataExportDefinition(columns, columnsName, "modules", "MÓDULOS", "module_id");

columns = new String[] {"user_id", "group_id"};
columnsName = new String[] {"USUÁRIO", "GRUPO"};
data[6] = new DataExportDefinition(columns, columnsName, "users_groups", "USUÁRIO X GRUPO", "user_id, group_id");

columns = new String[] {"user_id", "transaction_id"};
columnsName = new String[] {"USUÁRIO", "TRANSAÇÃO"};
data[7] = new DataExportDefinition(columns, columnsName, "users_transactions", "USUÁRIO X TRANSAÇÃO", "user_id, transaction_id");

columns = new String[] {"group_id", "transaction_id"};
columnsName = new String[] {"GRUPO", "TRANSAÇÃO"};
data[8] = new DataExportDefinition(columns, columnsName, "groups_transactions", "GRUPO X TRANSAÇÃO", "group_id, transaction_id");

columns = new String[] {"module_id", "transaction_id"};
columnsName = new String[] {"MÓDULO", "TRANSAÇÃO"};
data[9] = new DataExportDefinition(columns, columnsName, "modules_transactions", "MÓDULO X TRANSAÇÃO", "module_id, transaction_id");

ServletOutputStream fout = response.getOutputStream();

if (isXLS) {
	WorkbookSettings wbSettings = new WorkbookSettings();
	wbSettings.setLocale(new Locale("pt", "BR"));
	WritableWorkbook workbook = Workbook.createWorkbook(fout, wbSettings);

	for (int sheetPos = 0; sheetPos < data.length; sheetPos++) {
		DataExportDefinition exportData = data[sheetPos];
		
		WritableSheet sheet = workbook.createSheet(exportData.getTableName(), sheetPos);
		sheet.addCell(new Label(0, 0, exportData.getTableName()));
		
		// writing headers
		String[] headers = exportData.getHeaders();
		for (int j = 0; j < headers.length && j < XlsWriter.COLUMNS_LIMIT; j++)
			sheet.addCell(new Label(j, 1, headers[j]));
		
		// writing content
		String[][] content = exportData.getContent();
		for (int j = 0; j < content.length && j < XlsWriter.COLUMNS_LIMIT; j++) {
			for (int i = 0; i < content[j].length && i < XlsWriter.ROWS_LIMIT; i++) {
				if (content[j][i] != null) {
					String c;
					if (content[j][i].length() > XlsWriter.CELL_LIMIT) {
						c = content[j][i].substring(0, XlsWriter.CELL_LIMIT - 6) + " ...";
					}
					else {
						c = content[j][i];
					}
					
					sheet.addCell(new Label(j, i + 2, c));
				}
			}
		}
	}

	workbook.write();
	workbook.close();
}
else {
	XSSFWorkbook wb = new XSSFWorkbook();
	
	
	for (int sheetPos = 0; sheetPos < data.length; sheetPos++) {
		DataExportDefinition exportData = data[sheetPos];
		
		String safeName = WorkbookUtil.createSafeSheetName(exportData.getTableName());
		Sheet sheet = wb.createSheet(safeName);
		
		// Table name row
		Row tableNameRow = sheet.createRow(0);
		Cell c = tableNameRow.createCell(0);
		c.setCellValue(exportData.getTableName());
		
		// write header cells
		String[] headers = exportData.getHeaders();
		Row headerRow = sheet.createRow(1);
		for (int j = 0; j < headers.length && j < XlsxWriter.COLUMNS_LIMIT; j++) {
			c = headerRow.createCell(j);
			c.setCellValue(headers[j]);
		}
		
		// write content cells
		String[][] content = exportData.getContentXlsx();
		for (int i = 0; i < content.length && i < XlsxWriter.ROWS_LIMIT; i++) {
			Row row = sheet.createRow(i+2);
			for (int j = 0; j < content[i].length && j < XlsxWriter.COLUMNS_LIMIT; j++) {
				if (content[i][j] != null) {
					c = row.createCell(j);
					
					String s;
					if (content[i][j].length() > XlsxWriter.CELL_LIMIT) {
						s = content[i][j].substring(0, XlsxWriter.CELL_LIMIT - 6) + " ...";
					}
					else {
						s = content[i][j];
					}
					
					c.setCellValue(s);
				}
			}
		}
	}
	
	try {
		wb.write(fout);
	} catch (IOException e) {
		e.printStackTrace();
		System.err.println("XlsxWriter error while writing the xls.");
	}
}


fout.flush();
fout.close();

Logger logger = new Logger(session);
logger.log("Exportação de dados realizada.", "Definições", "Exportação de dados", "INSERT");
%>