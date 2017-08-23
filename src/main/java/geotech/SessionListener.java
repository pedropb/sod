package geotech;

import java.io.File;

import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
 
public class SessionListener implements HttpSessionListener {
	
	private static boolean excluiDiretorio(File arquivo)
	{
		File[] arquivosFilhos = arquivo.listFiles();
		
		for(int i = 0; i < arquivosFilhos.length; i++)
		{
			File filho = arquivosFilhos[i];
			
			if(filho.isDirectory())
				excluiDiretorio(filho);
			else
				filho.delete();
		}
		
		return arquivo.delete();
	}
 
    public void sessionCreated(HttpSessionEvent event) { 
        //System.out.println("Session Created: " + event.getSession().getId());
    }
 
    public void sessionDestroyed(HttpSessionEvent event) {

    	File diretorio = new File("tmp/" + event.getSession().getId());
    	if(diretorio.exists())
    	{
    		excluiDiretorio(diretorio);
    	}
    }
}