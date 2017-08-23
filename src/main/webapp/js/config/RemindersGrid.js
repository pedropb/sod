/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.config.Reminders', {
	extend: 'Ext.ux.GTGrid',
	
	columns: [{
		text     : '#',
		dataIndex: 'id',
		flex 	 : 1
	},{
		xtype    : 'datecolumn',
		text     : 'Data de Criação',
		dataIndex: 'created',
		format   : 'd/m/Y H:i:s',
		flex 	 : 3,
		hidden	 : true
	},{
		text     : 'Destinatário',
		dataIndex: 'recipient',
		flex	 : 3
	},{
		text     : 'Mensagem',
		dataIndex: 'message',
		flex	 : 10,
		renderer : function (v) {
			return v != null ? v.substring(0, 255) : "";
		}
	},{
		xtype    : 'datecolumn',
		text     : 'Próximo aviso',
		dataIndex: 'next_alarm',
		format   : 'd/m/Y',
		flex 	 : 3
	},{
		xtype    : 'datecolumn',
		text     : 'Visto em',
		dataIndex: 'last_viewed',
		format   : 'd/m/Y',
		flex 	 : 3
	},{
		text     : 'Autor',
		dataIndex: 'author',
		flex	 : 3,
		hidden	 : true
	},{
		xtype	 : 'checkcolumn',
		text     : 'Dispensado',
		hidden	 : true,
		dataIndex: 'dismissed',
		width	 : 100
	},{
		text     : 'Repetição',
		hidden	 : true,
		dataIndex: 'repeat'
	}],
	
	title: 'Lembretes',
	
	selModel: {
		mode: 'MULTI'
	},
	
	constructor: function (config) {
		var me = this;

		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.reminders);
		config.store.initialize();
		
		var ajaxParams = config.ajaxParams;
		var permissions = {};
		config.tbar = new Array();
		
		if (ajaxParams)
			permissions = ajaxParams.permissions;
		
		if (permissions.add) {
			config.addHandler = function () {
				Ext.create('Ext.window.Window', {
					
					title: 'Criação de lembretes',
					
					modal: true,
					closeAction: 'destroy',
					
					width: 600,
					height: 600,
					
					layout: 'fit',
					
					items: [{
						xtype: 'form',
						frame: true,
						border: false,
						bodyPadding: 10,
						autoScroll: true,
						layout: {
							type: 'column',
							manageOverflow: false
						},
						
						defaults: {
							margin: 5,
							columnWidth: 1,
							labelAlign: 'top'
						},
						
						items: [{
				    		xtype: 'gtinstructions',
				    		height: 120,
				    		instructions: [
				    		    '- Escolha os destinatários',
				    		    '- Defina a data a partir da qual o lembrete será exibido',
				    		    '- Defina a repetição do lembrete (em meses). Ex.: 01 - mensal, 03 - trimestral, 12 - anual.',
				    		    '- Preencha a mensagem',
				    		    '- Clique em enviar'
				    		]
				    	},{
							xtype: 'gtgrid',
							title: 'Destinatários',
							height: 200,
							exportable: false,
							selModel: {
								mode: 'MULTI'
							},
							addHandler: function (btn) {
				            	var parentGrid = btn.up('gtgrid');
				            	var targetStore = parentGrid.getStore();
				            	
				            	Ext.create('Ext.window.Window', {
				            		modal: true,
				            		layout: 'fit',
				            		width: 512,
				            		height: 386,
				            		title: 'Escolha os destinatários',
				            		items: [{
				            			xtype: 'gtusersgrid',
				            			preventHeader: true,
				            			exportable: false,
										selModel: {
											mode: 'MULTI'
										}
				            		}],
				            		buttons: [{
				            			text: 'Adicionar',
				            			handler: function (btn) {
				            				var win = btn.up('window');
				            				var grid = win.down('gtusersgrid');
				            				
				            				var selection = grid.getSelectedRecords();
				            				
				            				if (selection.length == 0) {
				            					Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro.');
				            					return;
				            				}
				            				
				            				targetStore.add(selection);
				            				win.close();
				            			}
				            		}]
				            	}).show();
							},
							removeHandler: function (btn) {
				            	var grid = btn.up('gtgrid');
								
								var selection = grid.getSelectedRecords();
								
								if (selection.length == 0) {
									Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro.');
									return;
								}
								
								grid.getStore().remove(selection);
							},
							columns: [{
								text     : 'Login',
								dataIndex: 'login',
								flex	 : 1
							}],
							store: Ext.create('Ext.data.Store', {
							    autoLoad: true,
							    model: 'UsuarioModel',
							    data : [],
							    proxy: {
							        type: 'memory'
							    }
							})
						},{
							xtype: 'datefield',
							name: 'next_alarm',
							columnWidth: .5,
							fieldLabel: 'Data de início',
							minValue: new Date(),
							allowBlank: false
						},{
							xtype: 'numberfield',
							name: 'repeat',
							allowDecimals: false,
							columnWidth: .5,
							fieldLabel: 'Repetição (meses)',
							minValue: 0,
							value: 0
						},{
				    		xtype: 'textarea',
				    		name: 'message',
				    		fieldLabel: 'Mensagem',
				    		height: 100,
				    		columnWidth: 1
				    	}]
					}],
					
					buttons: [{
						text: 'Criar',
						handler: function (btn) {
							var win = btn.up('window');
					    	
					    	var formElement = win.down('form');
							var form = formElement.getForm();
											
							if (form.isValid()) {
								
								var grid = win.down('gtgrid');
								var store = grid.getStore();
								
								var ids = new Array();
								for (var i = 0; i < store.data.length; i++) {
									ids.push(store.getAt(i).get('id'));
								}
								
								form.submit ({
					                waitMsg:'Salvando...',
					                waitTitle:'Aguarde',
					                url:'managers/config/reminders.jsp',
					                params: {
					                	action: 'add',
					                	ids: ids.join('@*@')
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
				                			GTPlanner.showErrorMessage('Criação de lembrete');
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
							btn.up('window').close();
						}
					}]
					
				}).show();
			};
		}
			
		if (permissions.remove) {
			config.removeHandler = function () {
				var selection = me.getSelectedRecords();
				if (selection.length == 0) {
					Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro.');
					return;
				}
				
				var n = selection.length;
				
				Ext.Msg.confirm('Atenção!', 'Deseja mesmo remover ' + n + ' lembrete(s) selecionado(s)?<br><b>Essa operação não pode ser desfeita.</b>', function (answer) {
					if (answer == 'yes') {
						Ext.Msg.wait('Removendo lembrete(s)...', 'Aguarde');
						
						var ids = "";
						for (var i = 0; i < selection.length; i++) {
							if (i > 0) {
								ids += "@*@";
							}
							
							ids += selection[i].get('id');
						}
						
						Ext.Ajax.request({
							url: 'managers/config/reminders.jsp',
							params: {
								action: 'remove',
								ids: ids 
							},
							success: function (response) {
								var result = GeoTech.utils.prepareServerResponse(response);
								
								if (result) {
									Ext.Msg.hide();
									GeoTech.utils.msg('Sucesso!', 'Lembrete(s) removido(s) com sucesso');
									me.getStore().load();
								}
							},
							failure: GeoTech.utils.prepareServerResponse
						});
					}
				});
			};
		}
		
		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
});