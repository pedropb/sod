package geotech.file;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

public class Manager
{	
	public static boolean checkIfFileExists (String file) {
		if (file == null)
			return false;
		
		File f = new File(file);
		return f.exists();
	}
	
	public static int moveFile(String source, String target) {
		target = target.replace("\\", File.separator).replace("/", File.separator);
		String targetDir = target.substring(0, target.lastIndexOf(File.separator) + 1);
		
		if(!checkFilePath(targetDir))
			return 0;
		
		File sourceFile = new File(source);
		File targetFile = new File(target);
        
		int transferedBytes = 0;
		
		try {
		 	InputStream input = new FileInputStream(sourceFile);
	        OutputStream output = new FileOutputStream(targetFile);
	        
	        byte[] buffer = new byte[1024];
	        int readBytes;
	        
	        while ((readBytes = input.read(buffer)) > 0) {
	        	output.write(buffer, 0, readBytes);
	        	transferedBytes += readBytes;
	        }
	        
	        input.close();
	        output.close();
		}
		catch(Exception e) {
			return -1;
		}
		
		return transferedBytes;
	}
	
	public static String getFileDir (String file) {
		file = file.replace('\\', '/');
		
		return file.substring(0, file.lastIndexOf("/") + 1);
	}
	
	public static int writeFile(String content, String target) {		
		target = target.replace("\\", File.separator).replace("/", File.separator);
		
		String targetDir = target.substring(0, target.lastIndexOf("/") + 1);
		
		if(!checkFilePath(targetDir))
			return 0;
		
		File targetFile = new File(target);
        
		int transferedBytes = 0;
		
		try {
		 	InputStream input = new ByteArrayInputStream(content.getBytes());
	        OutputStream output = new FileOutputStream(targetFile);
	        
	        byte[] buffer = new byte[1024];
	        int readBytes;
	        
	        while ((readBytes = input.read(buffer)) > 0) {
	        	output.write(buffer, 0, readBytes);
	        	transferedBytes += readBytes;
	        }
	        
	        input.close();
	        output.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		
		return transferedBytes;
	}
	
	public static boolean deleteFile(String path) {		
		File file = new File(path);
		
		if(file.exists()) {
			if(file.isDirectory())
				return deleteDir(file);
			else
				return file.delete();
		}
		
		return true;
	}
	
	private static boolean deleteDir(File file) {
		File[] childFiles = file.listFiles();
		
		for(int i = 0; i < childFiles.length; i++) {
			File childFile = childFiles[i];
			
			if(childFile.isDirectory())
				deleteDir(childFile);
			else
				childFile.delete();
		}
		
		return file.delete();
	}
	
	public static boolean checkFilePath(String path) {		
		File dir = new File(path);
		
		if(dir.exists()) {
			return true;
		}
		else {
			if(dir.mkdirs())
				return true;
			else
				return false;
		}
	}
	
	public static boolean renameFile(String source, String target) {		
		File oldFile = new File(source);
		File newFile = new File(target);
		
		if(oldFile.exists())
			return oldFile.renameTo(newFile);
		else
			return false;
	}
	
	public static boolean isAccessible(String path) {
		try {
			return (new File(path).exists());
		}
		catch(Exception e) {
			return false;
		}
	}
	
	public static long getFreeSpace(String filePath) {
		return ((new File(filePath)).getFreeSpace()) / 1048576; // Para transformar de byte para MB
	}
}
