package geotech;

import java.lang.management.ManagementFactory;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.management.AttributeNotFoundException;
import javax.management.InstanceNotFoundException;
import javax.management.MBeanException;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;
import javax.management.ObjectName;
import javax.management.Query;
import javax.management.QueryExp;
import javax.management.ReflectionException;

public class Utils {

	public static String verboseStringList(String[] items) {
		if (items == null)
			return "";
		else if (items.length <= 0)
			return "";
		else if (items.length == 1)
			return items[0];
		else {
			String result = "";
			int i = 0;
			for (i = 0; i < items.length - 2; i++) {
				result += items[i] + ", ";
			}
			result += items[i] + " e " + items[i + 1];

			return result;
		}
	}

	public static String join(String[] items) {
		return join(items, ",");
	}

	public static String join(String[] items, String separator) {
		if (items.length <= 0)
			return "";
		else {
			String result = items[0];
			for (int i = 1; i < items.length; i++)
				result += separator + items[i];

			return result;
		}
	}

	public static String escreveNumeroPontuado(String num) {
		return escreveNumeroPontuado(num, 2, false);
	}

	public static String escreveNumeroPontuado(String num, int precisao, boolean allDecimals) {
		if ((num == null) || (num.length() == 0))
			return "";

		return escreveNumeroPontuado(Double.parseDouble(num), precisao, allDecimals);
	}

	public static String escreveNumeroPontuado(double num) {
		return escreveNumeroPontuado(num, 2);
	}

	public static String escreveNumeroPontuado(double num, int precisao) {
		return escreveNumeroPontuado(num, precisao, false);
	}

	public static String escreveMoedaReal(double num) {
		return "R$ " + escreveNumeroPontuado(num, 2, true);
	}

	public static String escreveMoedaReal(String num) {
		return "R$ " + escreveNumeroPontuado(num, 2, true);
	}

	public static String escreveNumeroPontuado(double num, int precisao, boolean allDecimals) {
		String format = "#,##0.";

		for (int i = 0; i < precisao; i++)
			format += allDecimals ? "0" : "#";

		DecimalFormatSymbols dfs = new DecimalFormatSymbols();
		dfs.setDecimalSeparator(',');
		dfs.setGroupingSeparator('.');

		DecimalFormat df = new DecimalFormat(format, dfs);
		return df.format(num);
	}

	public static String computeElapsedTime(double initialTime) {
		double finalTime = System.nanoTime();
		return Math.round((finalTime - initialTime) / 1000000000) + "s";
	}

	public static List<String> getEndPoints()
			throws MalformedObjectNameException, NullPointerException, UnknownHostException, AttributeNotFoundException,
			InstanceNotFoundException, MBeanException, ReflectionException {
		MBeanServer mbs = ManagementFactory.getPlatformMBeanServer();
		QueryExp subQuery1 = Query.match(Query.attr("protocol"), Query.value("HTTP/1.1"));
		QueryExp subQuery2 = Query.anySubString(Query.attr("protocol"), Query.value("Http11"));
		QueryExp query = Query.or(subQuery1, subQuery2);
		Set<ObjectName> objs = mbs.queryNames(new ObjectName("*:type=Connector,*"), query);
		String hostname = InetAddress.getLocalHost().getHostName();
		InetAddress[] addresses = InetAddress.getAllByName(hostname);
		ArrayList<String> endPoints = new ArrayList<String>();
		for (Iterator<ObjectName> i = objs.iterator(); i.hasNext();) {
			ObjectName obj = i.next();
			String scheme = mbs.getAttribute(obj, "scheme").toString();
			String port = obj.getKeyProperty("port");
			for (InetAddress addr : addresses) {
				if (addr.isAnyLocalAddress() || addr.isLoopbackAddress() || addr.isMulticastAddress()) {
					continue;
				}
				String host = addr.getHostAddress();
				String ep = scheme + "://" + host + ":" + port;
				endPoints.add(ep);
			}
		}
		return endPoints;
	}
}