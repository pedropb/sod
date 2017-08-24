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

public class DataVerifyDefinition {

	private String[] columns;
	private String[] primaryKeys;
	private String table;
	private String checkTable;
	private List<String> errors;
	private List<String> differences;
	
	public DataVerifyDefinition(String[] columns, String[] primaryKeys, String table) {
		this.columns = columns;
		this.primaryKeys = primaryKeys;
		this.table = table;
		this.checkTable = "tmp_" + table;
		this.errors = new ArrayList<String>();
		this.differences = new ArrayList<String>();
	}
	
	public boolean verifyData(Sheet sheet) throws SQLException {
		Database db = Database.createDatabase();
		ResultSet result;
		String sql = "";
		
		StringBuilder sbSql = new StringBuilder();
		
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
				sbSql.append("(" + Utils.join(values, ",") + "),");
				foundData = true;
			}
			
			row++;
		}
		
		if (foundData) {
			// Creating temporary table for comparison purposes
			sql = 	"DROP TABLE IF EXISTS " + checkTable;
			db.execute(sql);
			
			sql = 	"CREATE TABLE " + checkTable + "\n" +
					"(\n";
			for (int i = 0; i < this.columns.length; i++) {
				if (i > 0)
					sql += ",";
				
				sql += "	" + columns[i] + " character varying(255)\n";
			}
			sql +=	")";
			db.execute(sql);
			
			// set db to transaction
//			System.out.println("Iniciando transação");
			db.setAutoCommit(false);
			db.save();
			
			// run query on temporary table
//			System.out.println("Importando dados");
			sbSql.deleteCharAt(sbSql.length() - 1); // removing last ,
			sql = "INSERT INTO " + checkTable + "(" + Utils.join(columns, ",") + ") VALUES ";
			sql += sbSql.toString();
			int totalCount = db.update(sql);
			success = totalCount >= 1;
			
			if (success) {
				// removing duplicates from temporary table
				System.out.println("Checando duplicatas");
				sql = "CREATE TEMPORARY TABLE tmp_" + checkTable + " AS SELECT DISTINCT * FROM " + checkTable;
				db.execute(sql);
				
				sql = "SELECT COUNT(*) FROM tmp_" + checkTable;
				result = db.query(sql);
				result.next();
				int distinctCount = result.getInt(1);
				
				int duplicateEntries = totalCount - distinctCount;
				if (duplicateEntries > 0) {
					System.out.println("Removendo duplicatas");
					sql = "TRUNCATE " + checkTable;
					db.execute(sql);
					sql = "INSERT INTO " + checkTable + " SELECT * FROM tmp_" + checkTable;
					db.update(sql);
					
					errors.add(sheet.getSheetName() + ": foram encontrados " + duplicateEntries + " registros que geram duplicatas no banco de dados.");
					errors.add(sheet.getSheetName() + ": confira se os dados foram apagados antes da importação e/ou se a planilha contém registros duplicados.");
				}
				
				// at this point our temporary table doesnt have duplicates neither constraints problem

				// create index to improve query performance
				db.execute("DROP INDEX IF EXISTS idx_" + checkTable + ";");
				db.execute("CREATE UNIQUE INDEX idx_" + checkTable + " ON " + checkTable + "("+ Utils.join(primaryKeys, ",") +")");
				
				success = (duplicateEntries == 0);
				
				db.commit();
				
				// Verify data
				System.out.println("Verificando " + table);
				sql = "SELECT " + Utils.join(columns, ",") + " FROM " + table + " EXCEPT SELECT " + Utils.join(columns, ",") + " FROM " + checkTable;
				result = db.query(sql);
				while (result.next()) {
					StringBuilder res = new StringBuilder();
					res.append("Registro (");
					for (int i = 0; i < columns.length; i++) {
						if (i > 0)
							res.append(", ");
						
						res.append(result.getString(columns[i]));
					}
					res.append(") da tabela " + sheet.getSheetName() + " está presente no banco de dados e não foi encontrado na planilha.");
					
					this.differences.add(res.toString());
				}
				
				sql = "SELECT " + Utils.join(columns, ",") + " FROM " + checkTable + " EXCEPT SELECT " + Utils.join(columns, ",") + " FROM " + table;
				result = db.query(sql);
				while (result.next()) {
					StringBuilder res = new StringBuilder();
					res.append("Registro (");
					for (int i = 0; i < columns.length; i++) {
						if (i > 0)
							res.append(", ");
						
						res.append(result.getString(columns[i]));
					}
					res.append(") da tabela " + sheet.getSheetName() + " está presente na planilha e não foi encontrado no banco de dados.");
					
					this.differences.add(res.toString());
				}
				
				// cleaning up
				sql = 	"DROP TABLE IF EXISTS " + checkTable;
				db.update(sql);
			}
			else {
				errors.add(sheet.getSheetName() + ": nenhum dado foi carregado");
				db.rollback();
			}
			
			// restore db to auto commit
			db.setAutoCommit(true);
		}
		else {
			success = false;
			errors.add(sheet.getSheetName() + ": nenhum dado foi carregado");
		}

		db.close();
		
		return success;
	}
	
	public String[] getErrors() {
		String[] result = new String[errors.size()];
		result = errors.toArray(result);
		
		return result;
	}
	
	public String[] getDifferences() {
		String[] result = new String[differences.size()];
		result = differences.toArray(result);
		
		return result;
	}
}
