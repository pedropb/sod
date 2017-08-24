package geotech.sod;

import geotech.Database;
import geotech.Utils;

import java.sql.ResultSet;
import java.sql.SQLException;

public class DataExportDefinition {

	private String[] columns;
	private String[] columnsName;
	private String table;
	private String tableName;
	private String order;
	
	public DataExportDefinition(String[] columns, String[] columnsName, String table, String tableName, String order) {
		this.columns = columns;
		this.columnsName = columnsName;
		this.table = table;
		this.tableName = tableName;
		this.order = order;
	}
	
	public DataExportDefinition(String[] columns, String[] columnsName, String table, String tableName) {
		this(columns, columnsName, table, tableName, "");
	}
	
	public String getTableName() {
		return tableName;
	}
	
	public String[][] getContent() throws SQLException {
		Database db = Database.createDatabase();
		
		String countSql = "SELECT COUNT(*) FROM " + table;
		ResultSet result = db.query(countSql);
		result.next();
		int count = result.getInt(1);
		
		String[][] content = new String[columns.length][count];

		String sql = "SELECT " + Utils.join(columns, ",") + " FROM " + table + (order != "" ? " ORDER BY " + order : "");
		result = db.query(sql);
		int row = 0;
		while (result.next()) {
			for (int i = 0; i < columns.length; i++) {
				content[i][row] = result.getString(columns[i]);
			}
			row++;
		}
		
		db.close();
		
		return content;
	}
	
	public String[][] getContentXlsx() throws SQLException {
		Database db = Database.createDatabase();
		
		String countSql = "SELECT COUNT(*) FROM " + table;
		ResultSet result = db.query(countSql);
		result.next();
		int count = result.getInt(1);
		
		String[][] content = new String[count][columns.length];

		String sql = "SELECT " + Utils.join(columns, ",") + " FROM " + table + (order != "" ? " ORDER BY " + order : "");
		result = db.query(sql);
		int row = 0;
		while (result.next()) {
			for (int i = 0; i < columns.length; i++) {
				content[row][i] = result.getString(columns[i]);
			}
			row++;
		}
		
		db.close();
		
		return content;
	}
	
	public String[] getHeaders() {
		return columnsName;
	}

}
