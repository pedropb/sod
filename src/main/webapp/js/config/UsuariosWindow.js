/*
 * GTPlanner Component - UsuáriosWindow
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.window.Usuarios', {
    extend: 'Ext.window.Window',
    
    closable: false,
    closeAction: 'destroy',
    modal: true,
    
    constructor: function (config) {
    	var me = this;
    	
    	var record = config.record;
    	me.editing = config.removeOnCancel != true;
	    		
		config.title = (me.editing ? 'Editar' : 'Adicionar') + ' Usuário';
		config.width = 520;
		config.height = 400;
		config.layout = 'fit';
		
		var grupoStoreParams = GTPlanner.stores.gruposPermissoesCmb;
		grupoStoreParams.listeners = {
			load: function (store) {
				store.insert(0, {id: -1, grupo: 'Nenhum grupo'});
			}
		};
		var grupoStore = Ext.create('Ext.ux.GTStore', GTPlanner.stores.gruposPermissoesCmb); 
					
		config.items = [{
			xtype: 'form',
	    	border: false,
	    	frame: true,
	    	bodyPadding: 10,
	    	layout: 'column',
	    	autoScroll: true,
	    	defaults: {
		    	labelAlign: 'left',
		        columnWidth: 1,
				padding: '0 0 8px 0',
				allowBlank: false
		    },
	    	items: [{
	    		xtype: 'checkbox',
				name: 'ativo',
				fieldLabel: 'Ativo',
				checked: record.get('ativo')
	    	},{
		        xtype: 'textfield',
		        fieldLabel: 'Login',
		        name: 'login',
		        value: record.get('login')
		    },{
				xtype: 'textfield',
				inputType: 'password',
				name: 'password',
				fieldLabel: 'Senha',
				minLength: 8,
				minLengthText: 'O número mínimo de caracteres para a senha é 8.',
				hidden: me.editing,
				disabled: me.editing
			},{
				xtype: 'textfield',
				inputType: 'password',
				name: 'password2',
				fieldLabel: 'Repita a senha',
				minLength: 8,
				minLengthText: 'O número mínimo de caracteres para a senha é 8.',
				hidden: me.editing,
				disabled: me.editing
			},{
		        xtype: 'combo',
		        name: 'grupo',
		        itemId: 'grupo',
		        store: grupoStore,
		        displayField: 'grupo',
		        valueField: 'id',
		        queryMode: 'local',
		        fieldLabel: 'Grupo',
				forceSelection: true,
				listeners: {
					select: function (combo) {
						var form = this.ownerCt;
						form.getComponent('permissions').loadPermissions(record.get('id'), combo.getValue());
					}
				}
		    },{
		    	xtype: 'gtpermissions',
				itemId: 'permissions',
				labelWidth: 220,
				userId: record.get('id'),
				groupId: record.get('grupo'),
				loadingMask: true,
				targetContainer: me
		    }]
	    }];
	    
		config.buttons = [{
			text: 'Salvar',
			icon: 'images/disk.png',
			formBind: true,
			handler: function(btn) {
				var win = btn.up('window');
				
				var formElement = me.down('form');
				var form = formElement.getForm();
								
				if (form.isValid()) {
					form.submit ({
	                    waitMsg:'Salvando...',
	                    waitTitle:'Aguarde',
	                    url:'managers/config/usuarios.jsp',
	                    params: {
	                    	action: 'edit',
	                    	id: record.get('id')
	                    },
	                    success: function(form, action) {
	                    	GeoTech.utils.msg("Sucesso!", action.result.message);
	                    	
	                    	win.close();
	                    	me.store.reload();
	                    },
	                    failure: function(form, action) {
	                    	if (action && action.result && typeof(action.result.message) == "string")
	                    		Ext.Msg.alert('Atenção!', action.result.message);
	                    	else {
	                    		if (me.editing)
	                    			GTPlanner.showErrorMessage('Edição de Usuário');
	                    		else
	                    			GTPlanner.showErrorMessage('Criação de Usuário');
	                    	}
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
				if (config.removeOnCancel) {
					Ext.Ajax.request({
						url: 'managers/config/usuarios.jsp',
						params: {
							action: 'remove',
							id: record.get('id')
						}
					});
				}
				
				btn.up('window').close();
			}
		}];
		
    	Ext.apply(me, config);
    	
    	me.callParent(arguments);
    	me.initConfig(config);
    },
    
    afterRender: function () {
    	var me = this;
    	
    	me.setLoading('Carregando...');
		var grupo = me.down('form').getComponent('grupo');
		grupo.getStore().load({
			callback: function () {
				if (me.editing)
					grupo.select(me.record.get('grupo'));
				else {
					grupo.select(-1);
				}
				
				me.setLoading(false);
			}
		});
    		
    	me.callParent(arguments);
    }
});
