/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.definitions.GroupsWindow', {
    extend: 'Ext.window.Window',
    
    closable: false,
    closeAction: 'destroy',
    modal: true,
    
    width : 400,
    height: 150,
    
    layout: 'fit',
    
    constructor: function (config) {
    	var me = this;
    	
    	var record = config.record;
    	if (!record) {
    		me.editing = false;
    		record = Ext.create('GroupModel');
    	}
    	else {
    		me.editing = true;
    	}
    	
		config.title = (me.editing ? 'Editar' : 'Adicionar') + ' Grupo';
					
		config.items = [{
			xtype: 'form',
	    	border: false,
	    	frame: true,
	    	bodyPadding: 10,
	    	layout: {
	    		type: 'column',
	    		manageOverflow: false
	    	},
	    	autoScroll: true,
	    	defaults: {
		    	labelAlign: 'left',
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
		        name: 'group_id',
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
                url:'managers/definitions/groups.jsp',
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
});
