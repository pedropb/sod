package geotech;

import javax.servlet.ServletContext;

import org.pentaho.di.core.KettleEnvironment;
import org.pentaho.di.core.exception.KettleException;
import org.pentaho.di.job.Job;
import org.pentaho.di.job.JobMeta;
import org.pentaho.di.repository.Repository;


public class KettleJavaClassExecutinJob {

	public void main(ServletContext ctx) {
		// TODO Auto-generated method stub
		 
		String file= ctx.getRealPath("WEB-INF/classes/load_matera.kjb");
		Repository repository=null;
		
		try {
			KettleEnvironment.init();
						
			JobMeta jobmeta=new JobMeta(file,repository);
			Job job=new Job(repository, jobmeta);
			
			job.start();
			job.waitUntilFinished();
			
			if(job.getErrors()>0){
				System.out.println("Error Executing Job");
			}
			else {
				System.out.println("Job executed successfully");
			}
			
		} catch (KettleException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

}
