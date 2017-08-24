<%@page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@page import="java.util.List,java.text.DateFormat,java.text.SimpleDateFormat,geotech.document.XlsxWriter,geotech.document.XlsWriter,geotech.Utils,org.json.JSONArray,org.json.JSONException,org.json.JSONObject,java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.HttpURLConnection,java.net.URL,java.net.URLEncoder"%><%
	response.setContentType("text/html");

	String title = request.getParameter("title");
	title = title == null || title.isEmpty() ? "sem-titulo" : title;

	String extension = "";
	boolean isXLS;
	if (request.getParameter("format") != null && request.getParameter("format").equals("XLS")) {
		isXLS = true;
		extension = ".xls";
	}
	else {
		isXLS = false;
		extension = ".xlsx";
	}

	response.setCharacterEncoding("UTF-8");
	response.addHeader("Content-Disposition","attachment; filename=\"" + title + extension + "\"");
	
	JSONObject storeParams = new JSONObject(request.getParameter("storeParams"));
		
	String storeUrl = storeParams.getString("url");

	String urlParameters = "limit=-1";
	
	try {
		JSONObject params = storeParams.getJSONObject("params");
		String [] names = JSONObject.getNames(params);
		
		if (names != null)
			for (String name : names) {
				if (name.equals("limit"))
					continue;
				
				urlParameters += "&" + name + "=" + URLEncoder.encode(params.optString(name), "UTF-8");
			}
	} catch (Exception e) {}
	
	String urlString = Utils.getEndPoints().get(0) + getServletContext().getContextPath() + "/" + storeUrl;
	URL url = new URL(urlString);
	HttpURLConnection httpCon = (HttpURLConnection) url.openConnection();
	
	String charset = "UTF-8";
	httpCon.setRequestProperty("Cookie", "JSESSIONID=" + session.getId());
	httpCon.setRequestProperty("Accept-Charset", charset);
	httpCon.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);
	
	httpCon.setDoOutput(true);
	httpCon.setRequestMethod("POST"); 

	//Send request
	DataOutputStream wr = new DataOutputStream (httpCon.getOutputStream());
	wr.writeBytes (urlParameters);
	wr.flush ();
	wr.close ();
	
	//Get Response	
	InputStreamReader reader = new InputStreamReader(httpCon.getInputStream(), charset);
	
	BufferedReader rd = new BufferedReader(reader);
    String line;
    
    StringBuffer storeResponse = new StringBuffer(); 
    while((line = rd.readLine()) != null) {
    	storeResponse.append(line);
    	storeResponse.append('\r');
    }

    rd.close();

	JSONArray columns = new JSONArray(request.getParameter("columns"));	
    JSONArray storeData = new JSONObject(storeResponse.toString()).getJSONArray("data");
    
    ServletOutputStream fout = response.getOutputStream();
    
    if (request.getParameter("format") != null && request.getParameter("format").equals("XLS")) {
    	String[] headers = new String [columns.length()];
    	String[][] content = new String [columns.length()][storeData.length()];

    	for (int j = 0; j < columns.length(); j++) {
        	JSONObject column = columns.getJSONObject(j);
        	headers[j] = column.getString("title");
    	}
    	
    	for (int i = 0; i < storeData.length(); i++) {
    		JSONObject record = storeData.getJSONObject(i);

        	for (int j = 0; j < columns.length(); j++) {
    	    	JSONObject column = columns.getJSONObject(j);
    	    	if (column.optString("type").equals("datecolumn")) {
    	    		try {
    	    			content[j][i] = ((DateFormat) new SimpleDateFormat("dd/MM/yyyy")).format(((DateFormat) new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS")).parse(record.optString(column.optString("index"))));
    	    		} catch (Exception e) {
    		    		content[j][i] = record.optString(column.optString("index"));
    	    		}
    	    	}
    	    	else {
    	    		content[j][i] = record.optString(column.optString("index"));
    	    	}
    	    	
        	}
    	}
    		
    	XlsWriter w = new XlsWriter();
    	w.write(fout, title, headers, content);
    }
    else {
    	String[] headers = new String [columns.length()];
    	String[][] content = new String [storeData.length()][columns.length()];

    	for (int j = 0; j < columns.length(); j++) {
        	JSONObject column = columns.getJSONObject(j);
        	headers[j] = column.getString("title");
    	}
    	
    	for (int i = 0; i < storeData.length(); i++) {
    		JSONObject record = storeData.getJSONObject(i);

        	for (int j = 0; j < columns.length(); j++) {
    	    	JSONObject column = columns.getJSONObject(j);
    	    	if (column.optString("type").equals("datecolumn")) {
    	    		try {
    	    			content[i][j] = ((DateFormat) new SimpleDateFormat("dd/MM/yyyy")).format(((DateFormat) new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS")).parse(record.optString(column.optString("index"))));
    	    		} catch (Exception e) {
    		    		content[i][j] = record.optString(column.optString("index"));
    	    		}
    	    	}
    	    	else {
    	    		content[i][j] = record.optString(column.optString("index"));
    	    	}
    	    	
        	}
    	}
    		
    	XlsxWriter w = new XlsxWriter();
    	w.write(fout, title, headers, content);
    }
    
    fout.flush();
	fout.close();
	
%>