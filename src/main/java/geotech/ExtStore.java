package geotech;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspWriter;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONWriter;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;

public class ExtStore {

	public static String prepareOrders(HttpServletRequest request) {
		// sorting
		String order = "";

		String orderAux = request.getParameter("sort");
		if (orderAux != null && orderAux.length() > 0) {
			try {
				JSONArray sortOrder = new JSONArray(orderAux);

				for (int i = 0; i < sortOrder.length(); i++) {
					JSONObject obj = sortOrder.getJSONObject(i);

					if (i > 0 && i < sortOrder.length() - 1)
						order += ",";

					order += obj.getString("property") + " " + obj.getString("direction");
				}
			}
			catch (Exception ex) {
				order = "";
			}

			order = " ORDER BY " + order;
		}

		return order;
	}

	public static String prepareFilters(HttpServletRequest request) {
		// filtering
		String filterAux = request.getParameter("filter");
		String filter = "";
		if (filterAux != null && filterAux.length() > 0) {
			try {
				JSONArray filters = new JSONArray(filterAux);
				ArrayList<String> searchParameters = new ArrayList<String>();

				for (int i = 0; i < filters.length(); i++) {
					JSONObject obj = filters.getJSONObject(i);

					String property = obj.getString("property");
					String value = StringEscapeUtils.escapeSql(obj.getString("value"));

					int idx = -1;
					if (value.length() > 0) {
						if (property.endsWith("-options")) {
							idx = property.indexOf("-options");

							// filter is a checkbox group with predefined text values

							String p = "a." + property.substring(0, idx);

							String[] values = value.split(";");
							
							if (values.length == 0)
								continue;

							filter += " AND ( ";

							for (int j = 0; j < values.length; j++) {
								if (j > 0 && j <= values.length - 1)
									filter += " OR ";

								filter += p + " SIMILAR TO '%\\m" + values[j] + "\\M%' ";
							}

							filter += " ) ";
						}
						else if (property.endsWith("-text")) {
							idx = property.indexOf("-text");

							// filter is a textfield
							String p = "a." + property.substring(0, idx);

							String[] values = value.split(";");
							
							if (values.length == 0)
								continue;

							filter += " AND ( ";

							for (int j = 0; j < values.length; j++) {
								if (j > 0 && j <= values.length - 1)
									filter += " OR ";

								filter += p + " ILIKE '%" + values[j] + "%' ";
							}

							filter += " ) ";
						}
						else if (property.endsWith("-interval")) {
							idx = property.indexOf("-interval");

							// filter is numeric or interval
							String p = "a." + property.substring(0, idx);

							String[] values = value.split(";");

							String aux = "";

							for (int j = 0; j < values.length - 1; j += 2) {
								if (j != 0)
									aux += " OR ";
								
								if (!values[j].isEmpty() && !values[j+1].isEmpty())
									aux += "(" + p + " >= " + values[j] + " AND " + p + " <= " + values[j+1] + ")";
								else if (!values[j].isEmpty())
									aux += "(" + p + " >= " + values[j] + ")";
								else if (!values[j+1].isEmpty())
									aux += "(" + p + " <= " + values[j+1] + ")";
							}

							if (!aux.isEmpty())
								filter += " AND ( " + aux + " ) ";
						}
						else if (property.endsWith("-dateinterval")) {
							idx = property.indexOf("-dateinterval");

							// filter is date
							String p = "a." + property.substring(0, idx);

							String[] values = value.split(";");

							String aux = "";

							for (int j = 0; j < values.length - 1; j += 2) {
								if (j != 0)
									aux += " OR ";
								
								if (!values[j].isEmpty() && !values[j+1].isEmpty())
									aux += "(" + p + " >= TO_DATE('" + values[j] + "', 'DD/MM/YYYY') AND " + p + " <= TO_DATE('" + values[j+1] + "', 'DD/MM/YYYY'))";
								else if (!values[j].isEmpty())
									aux += "(" + p + " >= TO_DATE('" + values[j] + "', 'DD/MM/YYYY'))";
								else if (!values[j+1].isEmpty())
									aux += "(" + p + " <= TO_DATE('" + values[j+1] + "', 'DD/MM/YYYY'))";
							}

							if (!aux.isEmpty())
								filter += " AND ( " + aux + " ) ";
						}
						else if (property.endsWith("-date")) {
							idx = property.indexOf("-date");

							// filter is date
							String p = "a." + property.substring(0, idx);
							
							searchParameters.add("TO_CHAR(" + p + ", 'DD/MM/YYYY')" + " ILIKE '%" + value + "%'");
						}
						else {
							searchParameters.add("a." + property + "||'' ILIKE '%" + value + "%'");
						}
					}
				}

				if (searchParameters.size() > 0) {
					filter = " WHERE TRUE " + filter + " AND (" + StringUtils.join(searchParameters, " OR ") + ") ";
				}
				else {
					filter = " WHERE TRUE " + filter + " ";
				}
			}
			catch (Exception ex) {
				filter = "";
			}
		}

		return filter;
	}

	public static String prepareLimits(HttpServletRequest request) {
		// paging
		String limit = (request.getParameter("limit") != null && !request.getParameter("limit").equals("-1") ? request.getParameter("limit") : "ALL");
		String start = (request.getParameter("start") != null && !request.getParameter("start").isEmpty()  ? request.getParameter("start") : "0");

		return " LIMIT " + limit + " OFFSET " + start;
	}

	public static String prepareSql(String sql, HttpServletRequest request) {
		return prepareSql(sql, request, true);
	}

	public static String prepareSql(String sql, HttpServletRequest request, boolean includeLimits) {
		String parsed = "";

		String order = prepareOrders(request);
		String filter = prepareFilters(request);

		parsed = "SELECT * FROM ("+ sql + ") a " + filter + order;

		if (includeLimits) {
			String limits = prepareLimits(request);
			parsed += limits;
		}

		return parsed;
	}

	public static String prepareTotalSql(String sql, HttpServletRequest request) {
		String parsed = "";

		String filter = prepareFilters(request);

		parsed = "SELECT COUNT(*) FROM ("+ sql + ") a " + filter;

		return parsed;
	}

	public static boolean generateStore(String sql, HttpServletRequest request, JspWriter out) {

		try {
			Database db = new Database();
			
			String totalSql = prepareTotalSql(sql, request);
			
			ResultSet result = db.query(totalSql);
			result.next();
			
			JSONWriter output = new JSONWriter(out);

			output.object();
			
			// TOTAL RECORD COUNT
			output.key("total").value(result.getInt(1));
			
			// DATA
			sql = prepareSql(sql, request);
			
			result = db.query(sql);

			ResultSetMetaData metadata = result.getMetaData();
			int columnCount = metadata.getColumnCount();
			String[] columns = new String[columnCount];
			for (int i = 0; i < columnCount; i++) {
				columns[i] = metadata.getColumnName(i + 1);
			}

			output.key("data").array();
			while (result.next()) {
				output.object();
				
				for (int i = 0; i < columnCount; i++) {
					output.key(columns[i]).value(result.getObject(columns[i]));
				}
				
				output.endObject();
			}
			output.endArray();
			output.endObject();
			
			db.close();

			return true;
		}
		catch (Exception ex) {
			System.err.println(ex);
			ex.printStackTrace();
			return false;
		}		
	}
	
	public static boolean generateChartStore(String sql, String otherSql, HttpServletRequest request, JspWriter out) {
		return generateChartStore(sql, otherSql, 8, "Outros", request, out);
	}
	
	public static boolean generateChartStore(String sql, String otherSql, int limit, String othersName, HttpServletRequest request, JspWriter out) {

		try {
			Database db = new Database();
			ResultSet result;
			
			JSONWriter output = new JSONWriter(out);

			output.object();
			
			// preparing sql
			sql = "SELECT t.id, t.name, t.quantity FROM (" + sql + ") t WHERE t.quantity > 0 ORDER BY t.quantity DESC, t.name LIMIT " + (limit + 1);
			
			// DATA
			String[] ids = new String[limit];
			
			result = db.query(sql);
			output.key("data").array();
			int i;
			for (i = 0; i < limit; i++) {
				if (result.next()) {
					output.object();
					output.key("id").value(result.getString("id"));
					output.key("name").value(result.getString("name"));
					output.key("quantity").value(result.getLong("quantity"));
					output.endObject();
					
					ids[i] = "'" + StringEscapeUtils.escapeSql(result.getString("id")) + "'";
				}
				else {
					break;
				}
			}
			
			if (i == limit) {
				otherSql = otherSql.replace("%TOP_ENTRIES%", Utils.join(ids, ","));
				
				result = db.query(otherSql);
				result.next();
				int sum = result.getInt(1);
				
				if (sum > 0) {
					output.object();
					output.key("id").value(othersName);
					output.key("name").value(othersName);
					output.key("quantity").value(sum);
					output.endObject();
				}
			}
			
			output.endArray();
			output.endObject();
			
			db.close();

			return true;
		}
		catch (Exception ex) {
			System.err.println(ex);
			ex.printStackTrace();
			return false;
		}		
	}
}
