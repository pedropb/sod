package geotech;

/* import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException; */
import javax.servlet.ServletContext;

import org.pentaho.di.core.KettleEnvironment;
import org.pentaho.di.core.exception.KettleException;
import org.pentaho.di.job.Job;
import org.pentaho.di.job.JobMeta;
import org.pentaho.di.repository.Repository;


public class KettleJavaClassExecutinJob {

	public void main(ServletContext servletContext) {
		// TODO Auto-generated method stub
		 
		String file= servletContext.getRealPath("WEB-INF/classes/load_matera.kjb");
		Repository repository=null;
		
		try {
			KettleEnvironment.init();
						
			JobMeta jobmeta=new JobMeta(file,repository);
			jobmeta.setParameterValue("csv_file", "sample.csv");
			jobmeta.setParameterValue("db", "sod");
			jobmeta.setParameterValue("hostname", "db");
			jobmeta.setParameterValue("pass", "1234");
			jobmeta.setParameterValue("port", "4642");
			jobmeta.setParameterValue("user", "sod");
			Job job=new Job(repository, jobmeta);

/*
Parameter	Default value	Description
csv_file	sample.csv		CSV file path
db			sod				Database name
hostname	localhost		Database hostname
pass		1234			Databasse password
port		4642			Database port
user		sod				Database username
*/
/* 			Context initialContext = new InitialContext();
			Context env = (Context) initialContext.lookup("java:comp/env");
			job.setParameterValue("csv_file", "sample.csv");
			job.setParameterValue("db", (String) env.lookup("database"));
			job.setParameterValue("hostname", (String) env.lookup("host"));
			job.setParameterValue("pass", (String) env.lookup("pass"));
			job.setParameterValue("port", (String) env.lookup("port"));
			job.setParameterValue("user", (String) env.lookup("user"));
 */
			job.start();
			job.waitUntilFinished();
			
			if(job.getErrors()>0){
				System.out.println("Error Executing Job");
			}
			else {
				// get job output!

				System.out.println("Job executed successfully");
			}
			
		} catch (KettleException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		/* } catch (NamingException e) {
			e.printStackTrace(); */
		}

	}

}
