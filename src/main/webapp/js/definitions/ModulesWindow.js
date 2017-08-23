/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.definitions.ModulesWindow', {
    extend: 'Ext.window.Window',
    
    closable: false,
    closeAction: 'destroy',
    modal: true,
    
    width : 500,
    height: 150,
    
    layout: 'fit',
    
    constructor: function (config) {
    	var me = this;
    	
    	var record = config.record;
    	if (!record) {
    		me.editing = false;
    		record = Ext.create('ModuleModel');
    	}
    	else {
    		me.editing = true;
    	}
    	
		config.title = (me.editing ? 'Editar' : 'Adicionar') + ' Módulo';
					
		config.items = [{
			xtype: 'form',
	    	border: false,
	    	frame: true,
	    	bodyPadding: 10,
	    	layout: {
	    		type: 'column',
	    		manageOverflow: false
	    	},
	    	defaults: {
		    	labelAlign: 'left',
		    	labelWidth: 140,
		        columnWidth: 1,
				padding: '0 0 8px 0',
				listeners: {
	         	   specialkey: {
	         		   fn: function(field, event) {
		         		   if (event.keyCode == Ext.EventObject.ENTER)
		         			   me.submitWindow();
	         		   }
	         	   }
				}
		    },
	    	items: [{
		        xtype: 'uppertextfield',
		        fieldLabel: 'ID',
		        name: 'module_id',
		        value: record.get('id'),
				allowBlank: false
		    },{
		        xtype: 'textfield',
		        fieldLabel: 'Nome',
		        name: 'name',
		        value: record.get('name')
			}]
	    }];
	    
		config.buttons = [{
			text: 'Salvar',
			icon: 'images/disk.png',
			formBind: true,
			handler: function(btn) {
				me.submitWindow();
			}
		},{
			text: 'Cancelar',
			handler: function (btn) {
				me.close();
			}
		}];
		
    	Ext.apply(me, config);
    	
    	me.callParent(arguments);
    	me.initConfig(config);
    },
    
    submitWindow: function () {
    	var me = this;
		var win = me;
		
		var formElement = me.down('form');
		var form = formElement.getForm();
						
		if (form.isValid()) {
			var params;
			
			if (me.editing) {
				params = {
					action: 'edit',
					id: me.record.get('id')
				};
			}
			else {
				params = {
					action: 'add'
				};
			}
			
			form.submit ({
                waitMsg:'Salvando...',
                waitTitle:'Aguarde',
                url:'managers/definitions/modules.jsp',
                params: params,
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
                			GTPlanner.showErrorMessage('Edição de Módulo');
                		else
                			GTPlanner.showErrorMessage('Criação de Módulo');
                	}
                }
            });
		}
		else {
			Ext.Msg.alert("Atenção!", "Existem erros no preenchimento do formulário.");
		}
    }
});
