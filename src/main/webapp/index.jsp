<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 

<%
if (session.getAttribute("userId") != null)
{
	response.sendRedirect("main.jsp");
	return;
}
%>
    
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br"> 
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="CACHE-CONTROL" content="NO-CACHE" />
	<meta http-equiv="expires" content="-1" />
	<link rel="shortcut icon" href="images/favicon.ico" />
	<title>SOD</title>
 
	<!-- ExtJS -->
	<link rel="stylesheet" type="text/css" href="ext-4.2/resources/css/ext-all-gray.css" />
	<script type="text/javascript" src="ext-4.2/ext-all.js"></script>
	<script type="text/javascript" src="ext-4.2/locale/ext-lang-pt_BR-utf8.js"></script>
	
	<!-- CSS -->
	<link rel="stylesheet" type="text/css" href="css/base.css" />	
	<link rel="stylesheet" type="text/css" href="css/geotech_utils.css" />
    
	<script type="text/javascript">
		function login(item){
			var window = item.up('window');
			var form = window.down('form').getForm();

			if (form.isValid()){				
				form.submit ({
                    waitMsg:'Autenticando...',
                    waitTitle:'Login',
                    url:'actions/login.jsp',
                    params: {
                    	action: 'login'
                    },
                    success:function(form, action){
                        Ext.MessageBox.wait('Entrando...', 'Aguarde');
						document.location.href = 'main.jsp';
                    },
                    failure:function(form, action)
                    {
                    	if(action && action.result && action.result.msg)
                    		Ext.MessageBox.alert('Atenção!', action.result.msg);
                    	else
                    		Ext.MessageBox.alert('Atenção!', 'Ocorreu um erro ao tentar realizar o login. Caso o erro persista, por favor entre em contato com o administrador.');
                    }
                });
			}
			else {
				Ext.MessageBox.alert('Atenção!', 'Login / Password inválido(s)!');
			}
		}
		
		Ext.onReady(function(){
			Ext.create('Ext.window.Window', {
				modal: true,
				width: 300,
				height: 160,
				closable: false,
				title: 'Painel de Risco',
				items: [{
					xtype: 'form',
					border: false,
					frame: true,
					bodyPadding: 18,
					items: [{
						xtype: 'textfield',
						fieldLabel: 'Login',
						itemId: 'username',
						name: 'username',
						allowBlank: false,
						listeners: {
			         	   specialkey: {
			         		   fn: function(field, event) {
				         		   if (event.keyCode == Ext.EventObject.ENTER)
				         			   login(field);
			         		   }
			         	   }
						}
					},{
						xtype: 'textfield',
		                inputType:'password',
						itemId: 'password',
						name: 'password',
						fieldLabel: 'Password',
						allowBlank: false,
						listeners: {
			         	   specialkey: {
			         		   fn: function(field, event) {
				         		   if (event.keyCode == Ext.EventObject.ENTER)
				         			  login(field);
			         		   }
			         	   }
						}
					}]
				}],
				buttons: [{
					text: 'Entrar',
					handler: login
				}]				
			}).show();
<%
	String message = (String) session.getAttribute("message");
	if (message != null && message.trim().length() > 0) {
		out.println("GeoTech.utils.showMessage('Atenção', '"+message.trim()+"')");
		session.removeAttribute("message");
	}
%>
		});
        </script> 
</head> 
 
<body> 
	<div id="msg-div"><div id="msg-ct"></div></div>
</body> 
</html>