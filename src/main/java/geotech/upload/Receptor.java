package geotech.upload;

import geotech.file.Utils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

public class Receptor
{
	@SuppressWarnings("unchecked")
	public static Map<String, ItemUpload> upload(HttpServletRequest request) {
		FileItemFactory factory = new DiskFileItemFactory();
		ServletFileUpload upload = new ServletFileUpload(factory);
		upload.setHeaderEncoding("UTF-8");
		
		Map<String,ItemUpload> result = new HashMap<String,ItemUpload>();
		
		try {
			List<FileItem> form = upload.parseRequest(request);
			
			for (Iterator<FileItem> i = form.iterator(); i.hasNext();) {
				FileItem item = (FileItem) i.next();
			    
				if (item.isFormField()) {
			    	result.put(item.getFieldName(), new ItemUpload(item.getFieldName(), item.getString(), ItemUpload.FORM));
			    }
				else {
				 	File outputFile = Utils.createTempFile(Utils.getFileExtension(item.getName()));
			        
				 	InputStream input = item.getInputStream();
			        OutputStream output = new FileOutputStream(outputFile);
			        
			        byte[] buffer = new byte[1024];
			        int readBytes;
			        while ((readBytes = input.read(buffer)) > 0) {
			        	output.write(buffer, 0, readBytes);
			        }
			        
			        input.close();
			        output.close();
			        
			        result.put(item.getFieldName(), new ItemUpload(item.getName(), outputFile.getAbsolutePath(), ItemUpload.FILE));
				}
				
				
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		
		return result;
	}
}
