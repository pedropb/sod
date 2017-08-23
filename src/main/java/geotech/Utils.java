package geotech;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;

public class Utils {
	
public static String verboseStringList (String[] items) {
	if (items == null)
		return "";
	else if (items.length <= 0) 
		return "";
	else if (items.length == 1)
		return items[0];
	else {
		String result = "";
		int i = 0;
		for (i=0; i < items.length - 2; i++) {
			result += items[i] + ", ";
		}
		result += items[i] + " e " + items[i+1];
		
		return result;
	}
}

public static String join (String[] items) {
	return join(items, ",");
}

public static String join (String[] items, String separator) {
	if (items.length <= 0) 
		return "";
	else {
		String result = items[0];
		for (int i = 1; i < items.length; i++)
			result += separator + items[i];
		
		return result;
	}
}

public static String escreveNumeroPontuado (String num) {
	return escreveNumeroPontuado(num, 2, false);
}

public static String escreveNumeroPontuado (String num, int precisao, boolean allDecimals) {
	if ((num == null) || (num.length() == 0))
		return "";
	
	return escreveNumeroPontuado(Double.parseDouble(num), precisao, allDecimals);
}

public static String escreveNumeroPontuado (double num) {
	return escreveNumeroPontuado(num, 2);
}

public static String escreveNumeroPontuado (double num, int precisao) {
	return escreveNumeroPontuado(num, precisao, false);
}

public static String escreveMoedaReal (double num)
{
	return "R$ " + escreveNumeroPontuado(num, 2, true);
}

public static String escreveMoedaReal (String num)
{
	return "R$ " + escreveNumeroPontuado(num, 2, true);
}

public static String escreveNumeroPontuado (double num, int precisao, boolean allDecimals) {
	String format = "#,##0.";
	
	for (int i = 0; i < precisao; i++)
		format += allDecimals ? "0" : "#";
	
	DecimalFormatSymbols dfs = new DecimalFormatSymbols();
	dfs.setDecimalSeparator(',');
	dfs.setGroupingSeparator('.');
			
	DecimalFormat df = new DecimalFormat(format, dfs);
	return df.format(num);		
}

public static String computeElapsedTime (double initialTime) {
	double finalTime = System.nanoTime();
	return Math.round((finalTime - initialTime) / 1000000000) + "s";		
}
	/*public static void main(String [] args) {
		String[] items0 = {};
		String[] items1 = { "Empresa A" };
		String[] items2 = { "Empresa A", "Empresa B" };
		String[] items3 = { "Empresa A", "Empresa B", "Empresa C" };
		System.out.println(join(items0));
		System.out.println(join(items1));
		System.out.println(join(items2));
		System.out.println(join(items3));
	}*/
}