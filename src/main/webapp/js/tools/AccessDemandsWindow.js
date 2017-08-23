/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.tools.AccessDemandsWindow', {
	extend: 'Ext.window.Window',
	
	title: 'Solicitação de Acesso',
	
	width: 600,
	height: 490,
	
	modal: true,
	
	layout: 'fit',
	
	mode: 'new',
	
	constructor: function (config) {
		var me = this;
		
		var hasAccessLevel = function (field) {
			if (!config.record || typeof(field) != "string")
				return false;
			
			var value = config.record.get('access_level' + field.substr(-1));
			
			if (!value)
				return false;
			
			if (field.indexOf('list') === 0) {
				return (value.indexOf('C') != -1);
			}
			else if (field.indexOf('include') === 0) {
				return (value.indexOf('I') != -1);
			}
			else if (field.indexOf('change') === 0) {
				return (value.indexOf('A') != -1);
			}
			else if (field.indexOf('remove') === 0) {
				return (value.indexOf('E') != -1);
			}
			else
				return false;
		};
		
		var storeConfig = Ext.clone(GTPlanner.stores.groups);
		storeConfig.noLimit = true;
		var groupsStore = Ext.create('Ext.ux.GTStore', storeConfig);
		groupsStore.initialize().sort('name');
		
		switch (config.mode) {
			case "new":
				config.readOnly = false;
				
//				config.record = Ext.create('AccessDemandModel', {});
				
				config.buttons = [{
					text: 'Criar',
					handler: function (btn) {
				    	var win = me;
				    	
				    	var formElement = win.down('form');
						var form = formElement.getForm();
										
						if (form.isValid()) {
							form.submit ({
				                waitMsg:'Salvando...',
				                waitTitle:'Aguarde',
				                url:'managers/tools/accessDemands.jsp',
				                params:  {
									action: 'add'
								},
				                success: function(form, action) {
				                	GeoTech.utils.msg("Sucesso!", action.result.message);
				                	
				                	win.close();
				                	win.store.reload();
				                },
				                failure: function(form, action) {
				                	if (action && action.result && typeof(action.result.message) == "string")
				                		Ext.Msg.alert('Atenção!', action.result.message);
				                	else {
			                			GTPlanner.showErrorMessage('Criação de solicitação de acesso');
				                	}
				                }
				            });
						}
						else {
							Ext.Msg.alert("Atenção!", "Existem erros no preenchimento do formulário.");
						}
				    }
				}, {
					text: 'Cancelar',
					handler: function (btn) {
						btn.up('window').close();
					}
				}];
				break;
			case "read":
				config.readOnly = true;
				
				if (config.record.get('status') != 'Em análise') {
					config.buttons = [{
						text: 'Visualizar justificativa',
						handler: function (btn) {
							Ext.create('GTPlanner.tools.ChangeDemandStatusWindow', {
								readOnly: true,
								record: config.record
							}).show();
						}
					}];
				}
				else {
					config.buttons = [{
						text: 'Fechar',
						handler: function (btn) {
							btn.up('window').close();
						}
					}];
				}
				
				break;
			case "approve":
				config.readOnly = true;
				
				config.buttons = [{
					text: 'Relatório de Conflitos',
					handler: function (btn) {
						Ext.Msg.wait('Analisando conflitos...', 'Aguarde');
						Ext.Ajax.request({
							url: 'managers/tools/accessDemands.jsp',
							params: {
								action: 'analyze_conflicts',
								copy_user_id: config.record.get('copy_user_id'),
								group1: config.record.get('group1'),
								group2: config.record.get('group2'),
								group3: config.record.get('group3')
							},
							success: function (response) {
								var result = GeoTech.utils.prepareServerResponse(response);
								if (!result)
									return;
								
								Ext.Msg.hide();
								Ext.create('Ext.window.Window', {
									width: 600,
									height: 200,
									
									title: 'Resultado',
									
									layout: 'fit',
									modal: true,
									
									bodyPadding: 10,
									
									items: [{
										xtype: 'textarea',
										readOnly: true,
										value: result.analysis
									}]
								}).show();
							},
							failure: GeoTech.utils.prepareServerResponse
						});
					}
				},{
					text: 'Alterar Status',
					handler: function (btn) {
						Ext.create('GTPlanner.tools.ChangeDemandStatusWindow', {
							readOnly: false,
							record: config.record,
							parentWin: btn.up('window')
						}).show();
					}
				}];
				
				break;
		}
		
		
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
		    	allowBlank: config.readOnly
		    },
	    	items: [{
		        xtype: 'textfield',
		        fieldLabel: 'Usuário de rede',
		        name: 'user_name',
		        columnWidth: .4,
		        value: config.readOnly ? config.record.get('user_name') : ''
			},{
		        xtype: 'textfield',
		        fieldLabel: 'Nome',
		        name: 'real_name',
		        columnWidth: .6,
		        value: config.readOnly ? config.record.get('real_name') : ''
			},{
				xtype: config.readOnly ? 'textfield' : 'combo',
				fieldLabel: 'Tipo de Solicitação',
				name: 'demand_type',
				columnWidth: .4,
				store: GTPlanner.tools.ACCESS_DEMANDS_CONSTANTS.TYPES,
				editable: false,
		        value: config.readOnly ? config.record.get('demand_type') : ''
			},{
				xtype: 'container',
				columnWidth: .6,
				hidden: config.readOnly
			},{
				xtype: 'textfield',
				fieldLabel: 'Status da Solicitação',
				columnWidth: .6,
				value: config.readOnly ? config.record.get('status') : '',
				readOnly: true,
				allowBlank: true,
				hidden: !config.readOnly
			},{
	    		xtype: 'tabpanel',
	    		columnWidth: 1,
	    		activeTab: !config.readOnly ? 0 : (config.record.get('copy_user_id') ? 1 : 0),
	    		defaults: {
	    			frame: true,
		    		defaults: {
		    			margin: 5,
				    	readOnly: config.readOnly
		    		},
		    		listeners: {
		    			activate: function (tab) {
		    				var items = tab.items.items;
		    				for (var i = 0; i < items.length; i++) {
		    					if (typeof(items[i].setDisabled) == "function") {
		    						items[i].setDisabled(false);
		    					}
		    				}
		    			},
		    			deactivate: function (tab) {
		    				var items = tab.items.items;
		    				for (var i = 0; i < items.length; i++) {
		    					if (typeof(items[i].setDisabled) == "function") {
		    						items[i].setDisabled(true);
		    					} 
		    				}
		    			}
		    		}
	    		},
	    		items: [{
	    			title: 'Novo Perfil',
		    		columnWidth: 1,
		    		layout: 'column',
		    		disabled: config.readOnly && config.record.get('copy_user_id'),
		    		defaults: {
		    			margin: 5,
			    		disabled: config.readOnly && config.record.get('copy_user_id'),
				    	readOnly: config.readOnly
		    		},
		    		
	    			items: [{
		    			xtype: 'label',
		    			text: 'Grupo:',
		    			columnWidth: .8
		    		},{
		    			xtype: 'label',
		    			text: 'C',
		    			columnWidth: .05
		    		},{
		    			xtype: 'label',
		    			text: 'I',
		    			columnWidth: .05
		    		},{
		    			xtype: 'label',
		    			text: 'A',
		    			columnWidth: .05
		    		},{
		    			xtype: 'label',
		    			text: 'E',
		    			columnWidth: .05
		    		},{
		    			xtype: 'combo',
		    			store: groupsStore,
		    			columnWidth: .8,
		    			displayField: 'name',
		    			valueField: 'id',
		    			name: 'group1',
				        value: config.readOnly ? config.record.get('group1') : '',
				        editable: false,
				        allowBlank: false
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			name: 'list1',
				        checked: config.readOnly ? hasAccessLevel('list1') : false
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			name: 'include1',
				        checked: config.readOnly ? hasAccessLevel('include1') : false
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			name: 'change1',
				        checked: config.readOnly ? hasAccessLevel('change1') : false
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			name: 'remove1',
				        checked: config.readOnly ? hasAccessLevel('remove1') : false
		    		},{
		    			xtype: 'combo',
		    			store: groupsStore,
		    			columnWidth: .8,
		    			displayField: 'name',
		    			valueField: 'id',
		    			name: 'group2',
				        editable: false,
				        value: config.readOnly ? config.record.get('group2') : ''
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			name: 'list2',
				        checked: config.readOnly ? hasAccessLevel('list2') : false
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			name: 'include2',
				        checked: config.readOnly ? hasAccessLevel('include2') : false
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			name: 'change2',
				        checked: config.readOnly ? hasAccessLevel('change2') : false
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			name: 'remove2',
				        checked: config.readOnly ? hasAccessLevel('remove2') : false
		    		},{
		    			xtype: 'combo',
		    			store: groupsStore,
		    			columnWidth: .8,
		    			margin: '5 5 10 5',
		    			displayField: 'name',
		    			valueField: 'id',
		    			name: 'group3',
				        editable: false,
				        value: config.readOnly ? config.record.get('group3') : ''
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			margin: '5 5 10 5',
		    			name: 'list3',
				        checked: config.readOnly ? hasAccessLevel('list3') : false
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			margin: '5 5 10 5',
		    			name: 'include3',
				        checked: config.readOnly ? hasAccessLevel('include3') : false
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			margin: '5 5 10 5',
		    			name: 'change3',
				        checked: config.readOnly ? hasAccessLevel('change3') : false
		    		},{
		    			xtype: 'checkbox',
		    			columnWidth: .05,
		    			margin: '5 5 10 5',
		    			name: 'remove3',
				        checked: config.readOnly ? hasAccessLevel('remove3') : false
		    		}]
	    			
	    		},{
	    			title: 'Copiar Perfil',
		    		layout: 'fit',
		    		disabled: config.readOnly && !config.record.get('copy_user_id'),
		    		items: [{
		    			xtype: config.readOnly ? 'textfield' : 'gtgridbox',
		    			fieldLabel: 'Selecione o usuário',
		    			name: 'copy_user_id',
		    			value: config.readOnly ? config.record.get('copy_user_id') : '',
    					labelWidth: 200,
    					displayField: 'id',
		    			margin: '5 5 10 5',

		    			disabled: (config.readOnly && !config.record.get('copy_user_id')) || !config.readOnly,
				    	readOnly: config.readOnly,
				        allowBlank: false,
		    			
		    			columns: [{
		    				text     : 'ID',
		    				dataIndex: 'id',
		    				flex	 : 1
		    			},{
		    				text     : 'Nome',
		    				dataIndex: 'name',
		    				flex	 : 3
		    			},{
		    				xtype    : 'datecolumn',
		    				text     : 'Data de criação',
		    				dataIndex: 'created',
		    				format   : 'd/m/Y',
		    				flex 	 : 1,
		    				hidden	 : true
		    			}],
		    			
		    			store: Ext.create('Ext.ux.GTStore',	GTPlanner.stores.users)
		    			
		    			
		    		}]
	    		}]
	    		,
	    	},{
	    		xtype: 'textarea',
	    		fieldLabel: 'Observações',
	    		name: 'obs',
	    		allowBlank: true,
	    		columnWidth: 1,
		        value: config.readOnly ? config.record.get('obs') : ''
	    	}]
		}];

		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
	
});