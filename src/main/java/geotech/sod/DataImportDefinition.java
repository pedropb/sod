package geotech.sod;

import geotech.Database;
import geotech.Utils;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;

public class DataImportDefinition {

	private Database db;
	private String[] columns;
	private String[] primaryKeys;
	private IndexDefinition[] indexes;
	private ForeignKeyConstraint[] references;
	
	private String table;
	private List<String> errors;
	private int count;
	
	public DataImportDefinition(String[] columns, String table, Database db, String[] primaryKeys) {
		this(columns, table, db, primaryKeys, new ForeignKeyConstraint[] {}, new IndexDefinition[] {});
	}
	
	public DataImportDefinition(String[] columns, String table, Database db, String[] primaryKeys, ForeignKeyConstraint[] constraints) {
		this(columns, table, db, primaryKeys, constraints, new IndexDefinition[] {});
	}
	
	public DataImportDefinition(String[] columns, String table, Database db, String[] primaryKeys, ForeignKeyConstraint[] constraints, IndexDefinition[] indexes) {
		this.columns = columns;
		this.primaryKeys = primaryKeys;
		this.table = table;
		this.errors = new ArrayList<String>();
		this.count = 0;
		
		this.indexes = indexes;
		this.references = constraints;
		
		this.db = db;
	}
	
	public boolean importData(Sheet sheet) throws SQLException {
		// build the query
		StringBuilder sbSql = new StringBuilder();
		String sql;
		ResultSet result;
		
		// initiate at row 2, to skip headers
		boolean success = true;
		boolean end = false;
		boolean foundData = false;
		int row = 2;
		
//		System.out.println("Preparando SQL");
		
		while (!end) {
			Row r = sheet.getRow(row);
			
			String[] values = new String[columns.length];
			for (int col = 0; col < columns.length; col++) {
				try {
					Cell cell = r.getCell(col);
					String content;
					
					if (cell.getCellType() == Cell.CELL_TYPE_STRING) {
						content = new String(cell.getStringCellValue().getBytes("ISO-8859-1"), "ISO-8859-1");
					}
					else {
						content = Long.toString(Math.round(cell.getNumericCellValue()));
					}
					
					content = content.trim();
					
					if (col == 0 && (
							content == null || 
							content.length() == 0 ||
							(cell.getCellType() == Cell.CELL_TYPE_BLANK)
						)) {
						end = true;
						break;
					}
					else {
						if (content == null || content.length() == 0) {
							values[col] = "NULL";
						}
						else {
							if (content.length() > 255)
								content = content.substring(0, 255);
							
							if (columns[col].equals("name") != true)
								content = content.toUpperCase();
							
							values[col] = "'" + StringEscapeUtils.escapeSql(content) + "'";
						}
					}
				}
				catch (Exception ex) {
					if (col == 0) {
						end = true;
						break;
					}
					else {
						continue;
					}
				}
			}
			
			if (!end) {
				sbSql.append("(" + Utils.join(values, ",") + ", now()" + "),");
				foundData = true;
			}
			
			row++;
		}
		
		int totalCount = 0;
		if (foundData) {
			String temporaryTableName = "t_" + table;
			
			// creating temporary table
			String createQuery = "DROP TABLE IF EXISTS " + temporaryTableName;
			db.execute(createQuery);
			createQuery = "CREATE TEMPORARY TABLE " + temporaryTableName + " AS TABLE " + table;
			db.execute(createQuery);
			
			// set db to transaction
//			System.out.println("Iniciando transação");
			db.setAutoCommit(false);
			db.save();
			
			// run query on temporary table
//			System.out.println("Importando dados");
			sbSql.deleteCharAt(sbSql.length() - 1); // removing last ,
			sql = "INSERT INTO " + temporaryTableName + "(" + Utils.join(columns, ",") + ", CREATED" + ") VALUES ";
			sql += sbSql.toString();
			totalCount = db.update(sql);
			success = totalCount >= 1;
			
			if (success) {
				// removing duplicates from temporary table
				System.out.println("Checando duplicatas");
				sql = "CREATE TEMPORARY TABLE tmp_" + temporaryTableName + " AS SELECT DISTINCT ON (" + Utils.join(primaryKeys, ",") + ") * FROM " + temporaryTableName;
				db.execute(sql);
				
				sql = "SELECT COUNT(*) FROM tmp_" + temporaryTableName;
				result = db.query(sql);
				result.next();
				int distinctCount = result.getInt(1);
				
				int duplicateEntries = totalCount - distinctCount;
				if (duplicateEntries > 0) {
					System.out.println("Removendo duplicatas");
					sql = "TRUNCATE " + temporaryTableName;
					db.execute(sql);
					sql = "INSERT INTO " + temporaryTableName + " SELECT * FROM tmp_" + temporaryTableName;
					db.update(sql);
					
					errors.add(sheet.getSheetName() + ": foram encontrados " + duplicateEntries + " registros que geram duplicatas no banco de dados.");
					errors.add(sheet.getSheetName() + ": confira se os dados foram apagados antes da importação e/ou se a planilha contém registros duplicados.");
				}
				
				// checking constraint integrity
				System.out.println("Checando integridade");
				int badIntegrityEntries = 0;
				for (int i=0; i<references.length; i++) {
					boolean hasProblem = false;
					result = db.query(references[i].getCheckConstraintSql(temporaryTableName));
					
					while (result.next()) {
						errors.add(sheet.getSheetName() + ": " + references[i].localColumn + " \"" + result.getString(1) + "\" não encontrado.");
						hasProblem = true;
					}
					
					if (hasProblem) {
						System.out.println("Consertando integridade");
						badIntegrityEntries += db.update(references[i].getEnforceConstraintSql(temporaryTableName));
					}
				}
				if (badIntegrityEntries > 0) {
					errors.add(sheet.getSheetName() + ": foram encontrados " + badIntegrityEntries + " que têm referências inválidas.");
					errors.add(sheet.getSheetName() + ": confira se as referências e os IDs estão idênticos na barra de fórmula do Excel.");
				}
				
				// at this point our temporary table doesnt have duplicates neither constraints problem
				
				// disables all triggers
//				System.out.println("Desabilitando triggers");
				String triggerQuery = "ALTER TABLE " + table + " DISABLE TRIGGER ALL";
				db.execute(triggerQuery);
				
				// dropping indexes
//				System.out.println("Removendo índices");
				for (int i=0; i<indexes.length; i++) {
					db.execute(indexes[i].getDropSql());
				}
				
				// reinsert data on the original table
				sql = "DELETE FROM " + table;
				db.execute(sql);
				
				sql = "INSERT INTO " + table + " SELECT * FROM " + temporaryTableName;
				db.update(sql);
				
				// recreating indexes
//				System.out.println("Recriando índices");
				for (int i=0; i<indexes.length; i++) {
					db.execute(indexes[i].getCreateSql(table));
				}
				
				// enabling triggers
//				System.out.println("Habilitando triggers");
				triggerQuery = "ALTER TABLE " + table + " ENABLE TRIGGER ALL";
				db.execute(triggerQuery);
				
				count = totalCount - duplicateEntries - badIntegrityEntries;
				success = ((duplicateEntries + badIntegrityEntries) == 0);
				
				
				db.commit();
			}
			else {
				db.rollback();
			}
			
			// restore db to auto commit
			db.setAutoCommit(true);
		}
		
		return success;
	}
	
	public String[] getErrors() {
		String[] result = new String[errors.size()];
		result = errors.toArray(result);
		
		return result;
	}
	
	public int getImportCount() {
		return count;
	}
}
