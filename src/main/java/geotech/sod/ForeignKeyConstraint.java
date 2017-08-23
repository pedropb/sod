package geotech.sod;

public class ForeignKeyConstraint {
	
	public String foreignTable;
	public String localColumn;
	public String foreignColumn;

	public ForeignKeyConstraint(String foreignTable, String localColumn, String foreignColumn) {
		this.foreignTable = foreignTable;
		this.localColumn = localColumn;
		this.foreignColumn = foreignColumn;
	}
	
	public ForeignKeyConstraint(String foreignTable, String localColumn) {
		this.foreignTable = foreignTable;
		this.localColumn = localColumn;
		this.foreignColumn = localColumn;
	}

	public String getCheckConstraintSql(String table) {
		return "SELECT DISTINCT t." + localColumn + " FROM " + table + " t WHERE t." + localColumn + " NOT IN (SELECT " + foreignColumn + " FROM " + foreignTable + ")"; 
	}
	
	public String getEnforceConstraintSql(String table) {
		return "DELETE FROM " + table + " t WHERE t." + localColumn + " NOT IN (SELECT " + foreignColumn + " FROM " + foreignTable + ")"; 
	}
	
	public String createFkConstraint(String table) {
		String sql;
		
		sql = 	"ALTER " + table + " \n" +
				"ADD CONSTRAINT fk_" + foreignTable + "_" + table + " \n" +
				"FOREIGN KEY (" + localColumn + ") REFERENCES " + foreignTable + " (" + foreignColumn + ") \n" +
				"MATCH FULL";
		
		return sql;
	}
	
	public static String createPkConstraint(String table, String primaryColumn) {
		String sql;
		
		sql = 	"ALTER " + table + " \n" +
				"ADD PRIMARY KEY pk_" + table + " (" + primaryColumn + ")";
		
		return sql;
	}
}
