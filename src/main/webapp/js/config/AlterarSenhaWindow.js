/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.window.AlterarSenha', {
    extend: 'Ext.window.Window',
    
    title: 'Alterar senha',
	closable: true,
	closeAction: 'destroy',
	width: 400,
	modal: true,
	layout: 'fit',
	align: 'center',
	modal: true,
    
    constructor: function (config) {
    	var me = this;
    	
    	if (!config)
    		config = {};
    		
    	config.height = config.admin ? 220 : 250;
    	
    	config.items = [{
    		xtype: 'form',
    		border: true,
	    	frame: true,
	    	bodyPadding: 10,
	    	layout: 'anchor',
	    	defaults: {
		    	labelAlign: 'left',
		        labelWidth: 110,
		        anchor: '100%',
				padding: '0 0 8px 0',
				allowBlank: false
		    },
	    	items: [{
				xtype: 'component',
				autoEl: {
					tag: 'div',
					style: {
						fontWeight: 'bold',
						marginBottom: '20px'
					},
					html: 'A nova senha deve ter no mínimo 8 caracteres. Para garantir a segurança, utilize uma senha com letras, números e símbolos.' 
				}
			},{
				xtype: 'textfield',
				inputType: 'password',
				name: 'current',
				fieldLabel: 'Senha atual',
				hidden: config.admin,
				allowBlank: config.admin
			},{
				xtype: 'textfield',
				inputType: 'password',
				name: 'newPassword',
				fieldLabel: 'Nova senha',
				minLength: 8,
				minLengthText: 'O número mínimo de caracteres para a senha é 8.'
			},{
				xtype: 'textfield',
				inputType: 'password',
				name: 'newPassword2',
				fieldLabel: 'Repita a nova senha',
				minLength: 8,
				minLengthText: 'O número mínimo de caracteres para a senha é 8.'
			}],
			buttons: [{
				text: 'Alterar',
				formBind: true,
				handler: function(btn) {
					var win = btn.up('window');
					var formElement = btn.up('form');
					var form = formElement.getForm();
									
					if (form.isValid()) {
						var values = form.getValues();
						if (values.newPassword != values.newPassword2) {
							var fields = form.getFields();
							fields.getAt(1).markInvalid("As senhas informadas não são iguais.");
							fields.getAt(2).markInvalid("As senhas informadas não são iguais.");
							
							Ext.Msg.alert("Atenção!", "As senhas informadas não são iguais.");
							return;
						}
						
						form.submit ({
		                    waitMsg:'Alterando senha...',
		                    waitTitle:'Aguarde',
		                    url:'actions/changePassword.jsp',
		                    params: {
		                    	admin: config.admin ? 1 : 0,
		                    	target: config.user_id
		                    },
		                    success: function(form,action) {
								win.close();
		                    	GeoTech.utils.msg("Senha alterada com sucesso", "A nova senha já está em vigor e deverá ser utilizada a partir de agora.");
		                    },
		                    failure: function(form,action) {
		                    	if (action && action.result && action.result.message)
                    				Ext.MessageBox.alert('Atenção!', action.result.message);
                    			else
                    				Ext.MessageBox.alert('Atenção!', 'Ocorreu um erro durante a troca da senha. Se o erro persistir, entre em contato com o administrador do sistema.');
		                    }
		                });
					}
					else {
						Ext.Msg.alert("Atenção!", "Existem erros no preenchimento do formulário.");
					}
				}
			},{
				text: 'Cancelar',
				handler: function (btn) {
					btn.up('window').close();
				}
			}]
    	}];
    	
    	Ext.apply(me, config);
    	
    	me.callParent(arguments);
    	me.initConfig(config);
    }
});
