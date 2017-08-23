/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.tools.ChangeDemandStatusWindow', {
	extend: 'Ext.window.Window',
	
	title: 'Status',
	
	width: 600,
	height: 265,
	
	modal: true,
	
	layout: 'fit',
	
	mode: 'new',
	
	constructor: function (config) {
		var me = this;
		
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
		    	labelAlign: 'top',
		    	margin: 5,
		    	readOnly: config.readOnly,
		    	columnWidth: .33
		    },
	    	items: [{
				xtype: 'combo',
				name: 'status',
				fieldLabel: 'Status',
				columnWidth: .34,
				value: config.record.get('status'),
				editable: false,
				store: GTPlanner.tools.ACCESS_DEMANDS_CONSTANTS.STATUS
			},{
		        xtype: 'textfield',
		        fieldLabel: 'Aprovador',
		        allowBlank: true,
		        readOnly: true,
		        value: config.record.get('approver')
			},{
				xtype: 'textfield',
				fieldLabel: 'Data Aprovação',
				allowBlank: true,
				readOnly: true,
				editable: false,
		        value: Ext.Date.format(config.record.get('updated'), 'd/m/Y H:i')
	    	},{
	    		xtype: 'textarea',
	    		fieldLabel: 'Justificativa',
	    		name: 'reason',
	    		columnWidth: 1,
	    		height: 100,
		        value: config.record.get('reason')
	    	}]
		}];
		
		if (!config.readOnly) {
			config.buttons = [{
				text: 'Alterar',
				handler: function (btn) {
			    	var win = me;
			    	
			    	var formElement = win.down('form');
					var form = formElement.getForm();
					
					if (form.findField('status').getValue() == 'Negado' && form.findField('reason').getValue().length == 0) {
						Ext.Msg.alert('Atenção!', 'Preenchimento da justificativa é obrigatório.');
					}
					else {
						form.submit ({
			                waitMsg:'Salvando...',
			                waitTitle:'Aguarde',
			                url:'managers/tools/accessDemands.jsp',
			                params:  {
								action: 'approve',
								id: config.record.get('id')
							},
			                success: function(form, action) {
			                	GeoTech.utils.msg("Sucesso!", action.result.message);
			                	
			                	win.parentWin.store.reload();
			                	win.parentWin.close();
			                	win.close();
			                },
			                failure: function(form, action) {
			                	if (action && action.result && typeof(action.result.message) == "string")
			                		Ext.Msg.alert('Atenção!', action.result.message);
			                	else {
		                			GTPlanner.showErrorMessage('Alteração do status de solicitação de acesso');
			                	}
			                }
			            });
					}
			    }
			},{
				text: 'Cancelar',
				handler: function (btn) {
					btn.up('window').close();
				}
			}];
		}

		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
	
});