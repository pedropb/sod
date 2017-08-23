package geotech.sod;

public class IndexDefinition {
	
	public String name;
	public String column;
	public String type;
	
	public IndexDefinition(String name, String column) {
		this(name, column, "btree");
	}

	public IndexDefinition(String name, String column, String type) {
		this.name = name;
		this.column = column;
		this.type = type;
	}
	
	public String getDropSql() {
		return "DROP INDEX IF EXISTS " + name;
	}
	
	public String getCreateSql(String table) {
		return "CREATE INDEX " + name + " ON " + table + " USING " + type + " (" + column + ")";
	}
}
