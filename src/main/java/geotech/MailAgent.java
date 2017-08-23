package geotech;

import javax.mail.*;
import javax.mail.internet.*;

import java.util.*;

public class MailAgent {
	
	public static Message getMessage(String recipients[ ], String subject, String message , String from) throws MessagingException {
		boolean debug = true;


		//Set the host smtp address
		// IF PROD
		Properties props = new Properties();
		props.put("mail.smtp.host", "smtp.task.com.br");
		props.put("mail.smtp.auth", "true");
		Authenticator auth = new SMTPAuthenticator();
		Session session = Session.getDefaultInstance(props, auth);

		// IF DEBUG
//		props.put("mail.smtp.host", "mail.geotechsolutions.com.br");
//		props.put("mail.smtp.auth", "true");
//		Authenticator auth = new SMTPAuthenticator();
//		Session session = Session.getDefaultInstance(props, auth);
		
		session.setDebug(debug);

		// create a message
		Message msg = new MimeMessage(session);

		// set the from and to address
		InternetAddress addressFrom = new InternetAddress(from);
		msg.setFrom(addressFrom);

		InternetAddress[] addressTo = new InternetAddress[recipients.length];
		for (int i = 0; i < recipients.length; i++)
		{
			addressTo[i] = new InternetAddress(recipients[i]);
		}
		msg.setRecipients(Message.RecipientType.TO, addressTo);


		// Setting the Subject and Content Type
		msg.setSubject(subject);
		msg.setContent(message, "text/html; charset=ISO-8859-1");
		
		return msg;
	}
	
	public static void sendMail(String recipient, String subject, String message, String replyTo) throws MessagingException {
		sendMail(new String [] {recipient}, subject, message, replyTo);
	}
	
	public static void sendMail(String recipients [], String subject, String message, String replyTo) throws MessagingException
	{
		String from = "sistema@avalicon.com.br";
		Message msg = getMessage(recipients, subject, message, from);
		InternetAddress[] addressReplyTo = new InternetAddress[1];
		addressReplyTo[0] = new InternetAddress(replyTo);
		msg.setReplyTo(addressReplyTo);
		Transport.send(msg);
	}
	
	public static void sendMail(String recipients [], String subject, String message) throws MessagingException
	{
		String from = "sistema@avalicon.com.br";
		Transport.send(getMessage(recipients, subject, message, from));
	}
}

/**
* SimpleAuthenticator is used to do simple authentication
* when the SMTP server requires it.
*/
class SMTPAuthenticator extends javax.mail.Authenticator
{
	// IF PROD
    public PasswordAuthentication getPasswordAuthentication()
    {
        String username = "sistema@avalicon.com.br";
        String password = "#avl9771";
        return new PasswordAuthentication(username, password);
    }

	/*	IF DEBUG
    public PasswordAuthentication getPasswordAuthentication()
    {
        String username = "geotech@geotechsolutions.com.br";
        String password = "iF)(u0p~Tg!K";
        return new PasswordAuthentication(username, password);
    }*/
}	
