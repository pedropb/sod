package geotech.file;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;

public class Utils
{
	public static File createTempFile(String extension)
	{
	    final File temp;

	    try {
	    	temp = File.createTempFile("sod" + Long.toString(System.nanoTime()), extension);
	    }
	    catch (IOException ex) {
	    	return null;
	    }

	    return (temp);
	}
	
	public static byte[] getFileBytes (String filePath) throws Exception
	{		
		File file = new File(filePath);
		FileInputStream input = new FileInputStream(file);
		
		byte[] buffer = new byte[4096];
		ByteArrayOutputStream output = new ByteArrayOutputStream();    
		 
		int readBytes = -1;  
		while ((readBytes = input.read(buffer, 0, buffer.length)) != -1)
		{  
			output.write(buffer, 0, readBytes);  
		} 
		
		output.flush();
		output.close();
		input.close(); 
		
		return output.toByteArray();
	}
	
	public static String getFileContent (String filePath) throws Exception
	{
		BufferedReader input = new BufferedReader(new FileReader(filePath));
		
		String line = "";
		String fileContent = "";
		while ((line = input.readLine()) != null)
		{
			fileContent += line;
		}
		input.close();
		
		return fileContent;
	}

	public static String getFileExtension(String fileName)
	{
		String extension = "";
		
		int index = fileName.lastIndexOf(".");
		
		if (index != -1)
			extension = fileName.substring(index, fileName.length());

		return extension.toLowerCase();
	}
}