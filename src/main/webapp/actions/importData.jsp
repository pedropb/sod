<%@page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@page import="geotech.sod.IndexDefinition"%>
<%@page import="geotech.sod.ForeignKeyConstraint"%>
<%@page import="org.apache.poi.ss.usermodel.Sheet"%>
<%@page import="org.apache.poi.ss.usermodel.Workbook"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="org.apache.poi.ss.usermodel.WorkbookFactory"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFWorkbook"%>
<%@page import="org.apache.commons.io.FileUtils"%>
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
<%@page import="geotech.sod.DataImportDefinition"%>
<%@page import="java.io.File"%>
<%
if (!Permissions.canWrite(session, "definitions_import_data", response, out))
	return;

JSONWriter output = new JSONWriter(out);

try {
	String o = "";
	double initialTime = System.nanoTime();
	
	ResultSet result;
	String sql = "";
	
	// load file
	Map<String, ItemUpload> uploadData = Receptor.upload(request);
	if (uploadData == null || uploadData.get("import_file") == null) {
		output.object();
		output.key("success").value(false);
		output.key("message").value("Nenhum arquivo foi carregado.");
		output.endObject();
	}
	else {
		Database db = Database.createDatabase();
		
		String sFile = uploadData.get("import_file").getValue();

		// clean database if requested
		boolean clean_db = uploadData.get("clean_db") != null ? uploadData.get("clean_db").getValue().equals("on") : false;
		boolean delUsers = uploadData.get("users") != null ? uploadData.get("users").getValue().equals("on") : false;
		boolean delGroups = uploadData.get("groups") != null ? uploadData.get("groups").getValue().equals("on") : false;
		boolean delModules = uploadData.get("modules") != null ? uploadData.get("modules").getValue().equals("on") : false;
		boolean delTransactions = uploadData.get("transactions") != null ? uploadData.get("transactions").getValue().equals("on") : false;
		boolean delActivities = uploadData.get("activities") != null ? uploadData.get("activities").getValue().equals("on") : false;
		boolean delConflicts = uploadData.get("conflicts") != null ? uploadData.get("conflicts").getValue().equals("on") : false;
		boolean delUsersSolutions = uploadData.get("users_solutions") != null ? uploadData.get("users_solutions").getValue().equals("on") : false;
		boolean delGroupsSolutions = uploadData.get("groups_solutions") != null ? uploadData.get("groups_solutions").getValue().equals("on") : false;
		int usersSolutions = 0;
		int groupsSolutions = 0;
		
		if (clean_db) {
			
			if (!delUsersSolutions) {
				// save users solutions before deleting everything
				
				// creating temporary table with signature
				sql = "DROP TABLE IF EXISTS tmp_users_solutions";
				db.execute(sql);
				
				sql = 	"CREATE TABLE tmp_users_solutions\n" +
						"(\n" +
						"  user_id character varying(255),\n" +
						"  conflict_id character varying(255),\n" +
						"  created timestamp without time zone,\n" +
						"  reason text,\n" +
						"  gt_user_id integer,\n" +
						"  reason_created timestamp without time zone,\n" +
						"  signature character varying[],\n" +
						"  CONSTRAINT pk_tmp_users_solutions PRIMARY KEY (user_id, conflict_id)\n" +
						")";
				db.execute(sql);
				
				sql = 	"INSERT INTO tmp_users_solutions(user_id, conflict_id, created, reason, gt_user_id, reason_created, signature)\n" +
						"SELECT\n" +
						"	us.user_id,\n" +
						"	us.conflict_id,\n" +
						"	us.created,\n" +
						"	us.reason,\n" +
						"	us.gt_user_id,\n" +
						"	us.reason_created,\n" +
						"	(SELECT\n" +
						"		ARRAY_AGG(ut.transaction_id ORDER BY ut.transaction_id)\n" +
						"	FROM\n" +
						"		(SELECT user_id, transaction_id FROM users_transactions WHERE user_id = us.user_id UNION SELECT ug.user_id, gt.transaction_id FROM groups_transactions gt INNER JOIN users_groups ug ON gt.group_id = ug.group_id WHERE us.user_id = ug.user_id) ut\n" +
						"		INNER JOIN transactions t ON t.transaction_id = ut.transaction_id\n" +
						"	WHERE\n" +
						"		t.activity_id = c.activity1 OR t.activity_id = c.activity2) AS signature\n" +
						"FROM\n" +
						"	users_solutions us\n" +
						"	INNER JOIN conflicts c ON c.conflict_id = us.conflict_id";
				usersSolutions = db.update(sql);
				
				o += "Encontrou " + usersSolutions + " aceites de usuários.\n";
				
				// if count == 0 then no users solutions are in the database, which means we can delete them also (simplifying the process)
				delUsersSolutions = (usersSolutions == 0);
			}
			
			if (!delGroupsSolutions) {
				// save groups solutions before deleting everything
				
				// creating temporary table with signature
				sql = "DROP TABLE IF EXISTS tmp_groups_solutions";
				db.execute(sql);
				
				sql = 	"CREATE TABLE tmp_groups_solutions\n" +
						"(\n" +
						"  group_id character varying(255),\n" +
						"  conflict_id character varying(255),\n" +
						"  created timestamp without time zone,\n" +
						"  reason text,\n" +
						"  gt_user_id integer,\n" +
						"  reason_created timestamp without time zone,\n" +
						"  signature character varying[],\n" +
						"  CONSTRAINT pk_tmp_groups_solutions PRIMARY KEY (group_id, conflict_id)\n" +
						")";
				db.execute(sql);
				
				sql = 	"INSERT INTO tmp_groups_solutions(group_id, conflict_id, created, reason, gt_user_id, reason_created, signature)\n" +
						"SELECT\n" +
						"	gs.group_id,\n" +
						"	gs.conflict_id,\n" +
						"	gs.created,\n" +
						"	gs.reason,\n" +
						"	gs.gt_user_id,\n" +
						"	gs.reason_created,\n" +
						"	(SELECT\n" +
						"		ARRAY_AGG(gt.transaction_id ORDER BY gt.transaction_id)\n" +
						"	FROM\n" +
						"		(SELECT * FROM groups_transactions WHERE group_id = gs.group_id) gt\n" +
						"		INNER JOIN transactions t ON t.transaction_id = gt.transaction_id\n" +
						"	WHERE\n" +
						"		t.activity_id = c.activity1 OR t.activity_id = c.activity2) AS signature\n" +
						"FROM\n" +
						"	groups_solutions gs\n" +
						"	INNER JOIN conflicts c ON c.conflict_id = gs.conflict_id";
				groupsSolutions = db.update(sql);
				
				o += "Encontrou " + groupsSolutions + " aceites de grupos.\n";
				
				// if count == 0 then no group solutions are in the database, which means we can delete them also (simplifying the process)
				delGroupsSolutions = (groupsSolutions == 0);
			}
			
			if (delUsers) {
				// Removing users
				db.cleanTable("users");

				o += "Removeu todos usuários e suas respectivas referências.\n";
			}
			
			if (delGroups) {
				// Removing groups
				db.cleanTable("groups");
				
				o += "Removeu todos grupos e suas respectivas referências.\n";
			}
			
			if (delModules) {
				// Removing modules
				db.cleanTable("modules");
				
				o += "Removeu todos módulos e suas respectivas referências.\n";
			}
			
			if (delTransactions) {
				// Removing transactions
				db.cleanTable("transactions");

				o += "Removeu todas transações e suas respectivas referências.\n";
			}
			
			if (delConflicts) {
				// Removing conflicts
				db.cleanTable("conflicts");

				o += "Removeu todos conflitos e suas respectivas referências.\n";
			}
			
			if (delActivities) {
				// Removing activities
				db.cleanTable("activities");

				o += "Removeu todas atividades e suas respectivas referências.\n";
			}
		}

		// this has to be in the same order of DataImportDefinition[] data below
		String[] sheetOrder = new String[] {
			"ATIVIDADES",
			"CONFLITOS",
			"TRANSAÇÕES",
			"USUÁRIOS",
			"GRUPOS",
			"MÓDULOS",
			"USUÁRIO X GRUPO",
			"USUÁRIO X TRANSAÇÃO",
			"GRUPO X TRANSAÇÃO",
			"MÓDULO X TRANSAÇÃO"
		};
		
		// this has to be in the same order of String[] sheetOrder above 
		DataImportDefinition[] data = new DataImportDefinition[10];
		String[] columns;
		String[] primaryKeys;
		IndexDefinition[] indexes;
		ForeignKeyConstraint[] references;

		columns = new String[] {"activity_id", "name"};
		primaryKeys = new String[] {"activity_id"};
		data[0] = new DataImportDefinition(columns, "activities", db, primaryKeys);
		
		columns = new String[] {"conflict_id", "name", "activity1", "activity2"};
		primaryKeys = new String[] {"conflict_id"};
		references = new ForeignKeyConstraint[] {
			new ForeignKeyConstraint("activities", "activity1", "activity_id"),
			new ForeignKeyConstraint("activities", "activity2", "activity_id")
		};
		indexes = new IndexDefinition[] {
			new IndexDefinition("index_10", "activity1"),
			new IndexDefinition("index_11", "activity2")
		};
		data[1] = new DataImportDefinition(columns, "conflicts", db, primaryKeys, references, indexes);
		
		columns = new String[] {"transaction_id", "name", "activity_id"};
		primaryKeys = new String[] {"transaction_id"};
		references = new ForeignKeyConstraint[] {
			new ForeignKeyConstraint("activities", "activity_id")
		};
		indexes = new IndexDefinition[] {
			new IndexDefinition("index_9", "activity_id")
		};
		data[2] = new DataImportDefinition(columns, "transactions", db, primaryKeys, references, indexes);
		
		columns = new String[] {"user_id", "name"};
		primaryKeys = new String[] {"user_id"};
		data[3] = new DataImportDefinition(columns, "users", db, primaryKeys);
		
		columns = new String[] {"group_id", "name"};
		primaryKeys = new String[] {"group_id"};
		data[4] = new DataImportDefinition(columns, "groups", db, primaryKeys);
		
		columns = new String[] {"module_id", "name"};
		primaryKeys = new String[] {"module_id"};
		data[5] = new DataImportDefinition(columns, "modules", db, primaryKeys);
		
		columns = new String[] {"user_id", "group_id"};
		primaryKeys = new String[] {"user_id", "group_id"};
		references = new ForeignKeyConstraint[] {
			new ForeignKeyConstraint("users", "user_id"),
			new ForeignKeyConstraint("groups", "group_id")
		};
		indexes = new IndexDefinition[] {
			new IndexDefinition("index_5", "user_id"),
			new IndexDefinition("index_6", "group_id")
		};
		data[6] = new DataImportDefinition(columns, "users_groups", db, primaryKeys, references, indexes);
		
		columns = new String[] {"user_id", "transaction_id"};
		primaryKeys = new String[] {"user_id", "transaction_id"};
		references = new ForeignKeyConstraint[] {
			new ForeignKeyConstraint("users", "user_id"),
			new ForeignKeyConstraint("transactions", "transaction_id")
		};
		indexes = new IndexDefinition[] {
			new IndexDefinition("index_3", "user_id"),
			new IndexDefinition("index_4", "transaction_id")
		};
		data[7] = new DataImportDefinition(columns, "users_transactions", db, primaryKeys, references, indexes);
		
		columns = new String[] {"group_id", "transaction_id"};
		primaryKeys = new String[] {"group_id", "transaction_id"};
		references = new ForeignKeyConstraint[] {
			new ForeignKeyConstraint("groups", "group_id"),
			new ForeignKeyConstraint("transactions", "transaction_id")
		};
		indexes = new IndexDefinition[] {
			new IndexDefinition("index_2", "group_id"),
			new IndexDefinition("index_1", "transaction_id")
		};
		data[8] = new DataImportDefinition(columns, "groups_transactions", db, primaryKeys, references, indexes);
		
		columns = new String[] {"module_id", "transaction_id"};
		primaryKeys = new String[] {"module_id", "transaction_id"};
		references = new ForeignKeyConstraint[] {
			new ForeignKeyConstraint("modules", "module_id"),
			new ForeignKeyConstraint("transactions", "transaction_id")
		};
		indexes = new IndexDefinition[] {
			new IndexDefinition("index_8", "module_id"),
			new IndexDefinition("index_7", "transaction_id")
		};
		data[9] = new DataImportDefinition(columns, "modules_transactions", db, primaryKeys, references, indexes);

		String header = "";
		String errors = "sem erros";
		
		File file = new File(sFile);
		Workbook workbook = WorkbookFactory.create(file);
			
		int sh = workbook.getNumberOfSheets();
		for (int i = 0; i < sheetOrder.length; i++) {
			boolean not_found = true;
			
			for (int j = 0; j < sh; j++) {
				Sheet sheet = workbook.getSheetAt(j);
				String sheetName = sheet.getSheetName();

				String target = sheetOrder[i];
				boolean hit = sheetName.equals(sheetOrder[i]);
				
				if (hit != true) {
					continue;
				}
				
				System.out.println("Iniciou importação: " + sheetName);
				boolean err = false;
					
				if (!data[i].importData(sheet)) {
					o += "\n" + Utils.join(data[i].getErrors(), "\n");
					errors = "com erros";
						
					err = true;
				}
					
				header += sheetOrder[i] + ": " + data[i].getImportCount() + " registros importados.\n";
				not_found = false;
					
				System.out.println("Fim importação: " + sheetName + " - " + (err ? "com erros" : "sem erros"));
			}
				
			if (not_found) {
				o += "\nNão encontrou planilha " + sheetOrder[i];
			}
		}
		
		// rebuilding cache table: users_activites
		db.cleanTable("users_activities");
		sql = 	"INSERT INTO users_activities(user_id, activity_id, counter)\n" +
				"SELECT\n" +
				"	ut.user_id,\n" +
				"	t.activity_id,\n" +
				"	COUNT(*)\n" +
				"FROM\n" +
				"	users_transactions ut\n" +
				"	INNER JOIN transactions t ON ut.transaction_id = t.transaction_id\n" +
				"WHERE\n" +
				"	t.activity_id is not NULL\n" +
				"GROUP BY ut.user_id, t.activity_id";
		db.update(sql);
		
		// rebuilding cache table: groups_activites
		db.cleanTable("groups_activities");
		sql = 	"INSERT INTO groups_activities(group_id, activity_id, counter)\n" +
				"SELECT\n" +
				"	gt.group_id,\n" +
				"	t.activity_id,\n" +
				"	COUNT(*)\n" +
				"FROM\n" +
				"	groups_transactions gt\n" +
				"	INNER JOIN transactions t ON gt.transaction_id = t.transaction_id\n" +
				"WHERE\n" +
				"	t.activity_id is not NULL\n" +
				"GROUP BY gt.group_id, t.activity_id";
		db.update(sql);
		
		if (clean_db) {
			if (!delUsersSolutions && usersSolutions > 0) {
				// restoring users solutions
				
				// cleaning up users and conflicts that doesn't exist anymore
				sql =	"DELETE FROM tmp_users_solutions\n" +
						"WHERE user_id NOT IN (SELECT user_id FROM users)\n" +
						"	OR conflict_id NOT IN (SELECT conflict_id FROM conflicts)\n" +
						"	OR gt_user_id NOT IN (SELECT id FROM gt_users)";
				db.update(sql);
				
				// this query selects all users transactions for a given us.user_id
				String usersTransactions = "";
				usersTransactions = "SELECT\n" +
									"	user_id,\n" + 
									"	transaction_id\n" +
									"FROM\n" +
									"	users_transactions\n" +
									"WHERE user_id = us.user_id\n" +
									"UNION\n" + 
									"SELECT\n" +
									"	ug.user_id,\n" +
									"	gt.transaction_id\n" +
									"FROM\n" +
									"	groups_transactions gt\n" +
									"	INNER JOIN users_groups ug ON gt.group_id = ug.group_id\n" +
									"WHERE ug.user_id = us.user_id";
				
				// this query builds the actual signature array of a given us.user_id and us.conflict_id
				sql = 	"SELECT\n" +
						"	ARRAY_AGG(ut.transaction_id ORDER BY ut.transaction_id) AS signature\n" + 
						"FROM\n" +
						"	conflicts c\n" +
						"	INNER JOIN transactions t ON t.activity_id = c.activity1 OR t.activity_id = c.activity2\n" +
						"	INNER JOIN (" + usersTransactions + ") ut ON ut.transaction_id = t.transaction_id\n" +
						"WHERE\n" +
						"	c.conflict_id = us.conflict_id";
				
				// this query recreates all users_solutions which signatures are the same in the current definitions
				sql = 	"INSERT INTO users_solutions(user_id, conflict_id, created, reason, gt_user_id, reason_created)\n" +
						"SELECT\n" +
						"	us.user_id,\n" +
						"	us.conflict_id,\n" +
						"	us.created,\n" +
						"	us.reason,\n" +
						"	us.gt_user_id,\n" +
						"	us.reason_created\n" +
						"FROM\n" +
						"	tmp_users_solutions us\n" +
						"WHERE\n" +
						"	us.signature <@ (" + sql + ")";
				int count = db.update(sql);
				
				o += count + " aceites de usuários foram mantidos.\n";
				o += (usersSolutions - count) + " aceites de usuários foram apagados.\n";
				
				sql = "DROP TABLE tmp_users_solutions";
				db.execute(sql);
			}
			
			if (!delGroupsSolutions && groupsSolutions > 0) {
				// restoring groups solutions
			
				// cleaning up groups and conflicts that doesn't exist anymore
				sql =	"DELETE FROM tmp_groups_solutions\n" +
						"WHERE group_id NOT IN (SELECT group_id FROM groups)\n" +
						"	OR conflict_id NOT IN (SELECT conflict_id FROM conflicts)\n" +
						"	OR gt_user_id NOT IN (SELECT id FROM gt_users)";
				db.update(sql);
				
				// this query selects all groups transactions for a given gs.group_id
				String groupsTransactions = "";
				groupsTransactions ="SELECT\n" +
									"	group_id,\n" + 
									"	transaction_id\n" +
									"FROM\n" +
									"	groups_transactions\n" +
									"WHERE group_id = gs.group_id";
				
				// this query builds the actual signature array of a given gs.group_id and gs.conflict_id
				sql = 	"SELECT\n" +
						"	ARRAY_AGG(gt.transaction_id ORDER BY gt.transaction_id) AS signature\n" + 
						"FROM\n" +
						"	conflicts c\n" +
						"	INNER JOIN transactions t ON t.activity_id = c.activity1 OR t.activity_id = c.activity2\n" +
						"	INNER JOIN (" + groupsTransactions + ") gt ON gt.transaction_id = t.transaction_id\n" +
						"WHERE\n" +
						"	c.conflict_id = gs.conflict_id";
				
				// this query recreates all groups_solutions which signatures are the same in the current definitions
				sql = 	"INSERT INTO groups_solutions(group_id, conflict_id, created, reason, gt_user_id, reason_created)\n" +
						"SELECT\n" +
						"	gs.group_id,\n" +
						"	gs.conflict_id,\n" +
						"	gs.created,\n" +
						"	gs.reason,\n" +
						"	gs.gt_user_id,\n" +
						"	gs.reason_created\n" +
						"FROM\n" +
						"	tmp_groups_solutions gs\n" +
						"WHERE\n" +
						"	gs.signature <@ (" + sql + ")";
				int count = db.update(sql);
				
				o += count + " aceites de grupos foram mantidos.\n";
				o += (groupsSolutions - count) + " aceites de grupos foram apagados.\n";
				
				sql = "DROP TABLE tmp_groups_solutions";
				db.execute(sql);
			}
		}

		db.close();
		
		o += "\nImportação finalizada " + errors + ".";
		double finalTime = System.nanoTime();
		o += "\nTempo decorrido: " + Math.round((finalTime - initialTime) / 1000000000) + "s";
		Logger logger = new Logger(session);
		logger.log("Importação de dados realizada. Resultado:\n" + o, "Definições", "Importação de dados", "INSERT");

		output.object();
		output.key("success").value(true);
		output.key("output").value(header + "\n" + o);
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