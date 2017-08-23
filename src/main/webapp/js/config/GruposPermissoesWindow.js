/*
 * GTPlanner Component - GruposPermissoesWindow
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.window.GruposPermissoes', {
    extend: 'Ext.window.Window',
    
    closable: false,
    closeAction: 'destroy',
    modal: true,
    
    constructor: function (config) {
    	var me = this;
    	
    	var record = config.record;
    	me.editing = config.removeOnCancel != true;
	    		
		config.title = (me.editing ? 'Editar' : 'Adicionar') + ' Grupo';
		config.width = 520;
		config.height = 400;
		config.layout = 'fit';
					
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
		        xtype: 'textfield',
		        fieldLabel: 'Grupo',
		        name: 'grupo',
		        value: record.get('grupo')
		    },{
		        xtype: 'textfield',
		        fieldLabel: 'Descrição',
		        name: 'descricao',
		        value: record.get('descricao')
			},{
		    	xtype: 'gtpermissions',
				itemId: 'permissions',
				labelWidth: 220,
				groupId: record.get('id')
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
	                    url:'managers/config/gruposPermissoes.jsp',
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
	                    			GTPlanner.showErrorMessage('Edição de Grupo');
	                    		else
	                    			GTPlanner.showErrorMessage('Criação de Grupo');
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
						url: 'managers/config/gruposPermissoes.jsp',
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
    }
});
