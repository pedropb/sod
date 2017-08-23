package geotech.upload;

public class ItemUpload
{
	/*
	 * Attributes
	 */
	String name = null;
	String value = null;
	int type = -1;	
	
	/*
	 * Class variables
	 */
	public static int FORM = 0;
	public static int FILE = 1;
	
	public ItemUpload()
	{
		this.name = "";
		this.value = "";
	}
	
	public ItemUpload(String name, String value, int type)
	{
		this.name = name;
		this.value = value;
		this.type = type;
	}
	
	public String toString()
	{
		return ("(name = " + this.name + ", value = " + this.value + ", type = " + type + ")");
	}
	
	public String getName()
	{
		return this.name;
	}
	
	public String getValue()
	{
		return this.value;
	}
	
	public int getType()
	{
		return this.type;
	}
}
