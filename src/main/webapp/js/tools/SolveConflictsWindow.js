/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.tools.SolveConflictsWindow', {
    extend: 'Ext.window.Window',
    
    closable: true,
    closeAction: 'destroy',
    modal: true,
    
    width : 800,
    height: 610,
    
    layout: 'fit',
    
    title: 'Dados do Conflito',
    
    constructor: function (config) {
    	var me = this;
    	
    	var record = config.record;
    	me.conflictType = config.conflictType;
    	
    	var baseForm = {
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
				readOnly: true
		    },
	    	items: [{
	    		xtype: 'checkbox',
	    		fieldLabel: 'Aceito',
	    		checked: record.get('accepted'),
				readOnly: false,
	    		listeners: {
	    			change: function (chk) {
	    				if (chk.getValue()) {
	    					Ext.create('Ext.window.Window', {
		    					title: 'Motivo',
		    					layout: 'fit',
		    					modal: true,
		    					closable: false,
		    					width: 600,
		    					height: 300,
		    					items: [{
		    						xtype: 'form',
		    				    	border: false,
		    				    	frame: true,
		    						bodyPadding: 10,
		    						layout: 'fit',
		    						items: [{
			    						xtype: 'textarea',
			    						labelAlign: 'top',
			    						fieldLabel: 'Descreva o motivo para a aceitação do conflito',
			    						allowBlank: false
			    					}]
		    					}],
		    					buttons: [{
		    						text: 'Salvar',
		    						icon: 'images/disk.png',
		    						handler: function (btn) {
		    							var win = btn.up('window');
		    							var form = win.down('form');
		    							
		    							if (form.isValid()) {
		    								var textarea = form.down('textarea');
		    								
		    								Ext.Msg.wait('Marcando conflito como aceito...', 'Aguarde');
			    							Ext.Ajax.request({
			    								url: 'managers/tools/solveConflicts.jsp',
			    								params: {
			    									action: 'accept',
			    									origin: me.isUserConflict() ? 'user' : 'group',
	    											origin_id: me.isUserConflict() ? me.record.get('user_id') : me.record.get('group_id'),
			    									conflict_id: me.record.get('conflict_id'),
			    									reason: textarea.getValue()
			    								},
			    								success: function (response) {
			    									var result = GeoTech.utils.prepareServerResponse(response);
			    									if (!result)
			    										return;
			    									
			    									win.close();
			    									
			    									Ext.Msg.confirm('Atenção!', 'O conflito foi marcado como aceito. Deseja voltar a tela de seleção de conflitos?', function (answer) {
			    										if (answer == 'yes') {
			    											me.close();
			    											GTPlanner.app.activeTab.activeForm.getStore().load();
			    										}
			    									});
			    								},
			    								failure: GeoTech.utils.prepareServerResponse
			    							});
		    							}
		    							else {
		    								Ext.Msg.alert('Atenção!', 'A descrição do motivo é obrigatória.');
		    							}
		    						}
		    					},{
		    						text: 'Cancelar',
		    						handler: function (btn) {
		    							chk.setRawValue(false);
		    							btn.up('window').close();
		    						}
		    					}]
		    				}).show();
	    				}
	    				else {
	    					Ext.Msg.confirm('Atenção!', 'Tem certeza que deseja descartar o aceite deste conflito?', function (answer) {
	    						if (answer == 'yes') {
	    							Ext.Msg.wait('Descartando aceite...', 'Aguarde');
	    							Ext.Ajax.request({
	    								url: 'managers/tools/solveConflicts.jsp',
	    								params: {
	    									action: 'remove_accept',
	    									origin: me.isUserConflict() ? 'user' : 'group',
	    									origin_id: me.isUserConflict() ? me.record.get('user_id') : me.record.get('group_id'),
	    									conflict_id: me.record.get('conflict_id')
	    								},
	    								success: function (response) {
	    									var result = GeoTech.utils.prepareServerResponse(response);
	    									if (!result)
	    										return;
	    									
	    	    							Ext.Msg.hide();
											GTPlanner.app.activeTab.activeForm.getStore().load();
	    								},
	    								failure: GeoTech.utils.prepareServerResponse
	    							});
	    						}
	    						else {
	    							chk.setRawValue(false);
	    						}
	    					});
	    					
	    				}
	    			}
	    		}
	    	},{
		        xtype: 'textfield',
		        fieldLabel: me.isUserConflict() ? 'Usuário' : 'Grupo',
		        value: record.get('name')
		    },{
		        xtype: 'textfield',
		        fieldLabel: 'Conflito',
		        value: record.get('conflict')
			}]
		};
    	
    	if (me.isUserConflict()) {
    		var storeGroups1 = Ext.create('Ext.ux.GTStore', GTPlanner.stores.usersGroupsConflicts);
			storeGroups1.getProxy().extraParams = {
				user_id: record.get('user_id'),
				conflict_id: record.get('conflict_id'),
				activity: 1
			};
			storeGroups1.initialize();
			
			var storeGroups2 = Ext.create('Ext.ux.GTStore', GTPlanner.stores.usersGroupsConflicts);
			storeGroups2.getProxy().extraParams = {
				user_id: record.get('user_id'),
				conflict_id: record.get('conflict_id'),
				activity: 2
			};
			storeGroups2.initialize();
			
			var storeTransactions1 = Ext.create('Ext.ux.GTStore', GTPlanner.stores.usersTransactionsConflicts);
			storeTransactions1.getProxy().extraParams = {
				user_id: record.get('user_id'),
				conflict_id: record.get('conflict_id'),
				activity: 1
			};
			storeTransactions1.initialize();
			
			var storeTransactions2 = Ext.create('Ext.ux.GTStore', GTPlanner.stores.usersTransactionsConflicts);
			storeTransactions2.getProxy().extraParams = {
				user_id: record.get('user_id'),
				conflict_id: record.get('conflict_id'),
				activity: 2
			};
			storeTransactions2.initialize();
			
			baseForm.items.push({
				xtype: 'fieldset',
				title: record.get('activity1'),
				columnWidth: .5,
				margin: '0 10px 0 0',
				layout: {
					type: 'vbox',
					align: 'stretch'
				},
				defaults: {
					xtype: 'gtgrid',
					searchable: false,
					exportable: false,
					height: 200,
					margin: 5,
					columns: [{
						text: 'ID',
						dataIndex: 'id',
						flex: 1
					},{
						text: 'Nome',
						dataIndex: 'name',
						flex: 1
					}]
				},
				items: [{
					title: 'Grupos',
					removeHandler: function (btn) {
						var grid = btn.up('gtgrid');
						var selection = grid.getSelectedRecords();
						
						if (selection.length == 0) {
							Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro.');
							return;
						}
						
						me.removeConflict(selection[0], 'group', grid);
					},
					store: storeGroups1
				},{
					title: 'Transações',
					removeHandler: function (btn) {
						var grid = btn.up('gtgrid');
						var selection = grid.getSelectedRecords();
						
						if (selection.length == 0) {
							Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro.');
							return;
						}
						
						me.removeConflict(selection[0], 'transaction', grid);
					},
					store: storeTransactions1
				}]
			});
			
			baseForm.items.push({
				xtype: 'fieldset',
				title: record.get('activity2'),
				columnWidth: .5,
				bodyPadding: 10,
				layout: {
					type: 'vbox',
					align: 'stretch'
				},
				defaults: {
					xtype: 'gtgrid',
					searchable: false,
					exportable: false,
					height: 200,
					margin: 5,
					columns: [{
						text: 'ID',
						dataIndex: 'id',
						flex: 1
					},{
						text: 'Nome',
						dataIndex: 'name',
						flex: 1
					}]
				},
				items: [{
					title: 'Grupos',
					removeHandler: function (btn) {
						var grid = btn.up('gtgrid');
						var selection = grid.getSelectedRecords();
						
						if (selection.length == 0) {
							Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro.');
							return;
						}
						
						me.removeConflict(selection[0], 'group', grid);
					},
					store: storeGroups2
				},{
					title: 'Transações',
					removeHandler: function (btn) {
						var grid = btn.up('gtgrid');
						var selection = grid.getSelectedRecords();
						
						if (selection.length == 0) {
							Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro.');
							return;
						}
						
						me.removeConflict(selection[0], 'transaction', grid);
					},
					store: storeTransactions2
				}]
			});
    	}
    	else {
			var storeTransactions1 = Ext.create('Ext.ux.GTStore', GTPlanner.stores.groupsTransactionsConflicts);
			storeTransactions1.getProxy().extraParams = {
				group_id: record.get('group_id'),
				conflict_id: record.get('conflict_id'),
				activity: 1
			};
			storeTransactions1.initialize();
			
			var storeTransactions2 = Ext.create('Ext.ux.GTStore', GTPlanner.stores.groupsTransactionsConflicts);
			storeTransactions2.getProxy().extraParams = {
				group_id: record.get('group_id'),
				conflict_id: record.get('conflict_id'),
				activity: 2
			};
			storeTransactions2.initialize();
			
			baseForm.items.push({
				xtype: 'fieldset',
				title: record.get('activity1'),
				columnWidth: .5,
				margin: '0 10px 0 0',
				layout: {
					type: 'vbox',
					align: 'stretch'
				},
				defaults: {
					xtype: 'gtgrid',
					searchable: false,
					exportable: false,
					height: 400,
					margin: 5,
					columns: [{
						text: 'ID',
						dataIndex: 'id',
						flex: 1
					},{
						text: 'Nome',
						dataIndex: 'name',
						flex: 1
					}]
				},
				items: [{
					title: 'Transações',
					removeHandler: function (btn) {
						var grid = btn.up('gtgrid');
						var selection = grid.getSelectedRecords();
						
						if (selection.length == 0) {
							Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro.');
							return;
						}
						
						me.removeConflict(selection[0], 'transaction', grid);
					},
					store: storeTransactions1
				}]
			});
			
			baseForm.items.push({
				xtype: 'fieldset',
				title: record.get('activity2'),
				columnWidth: .5,
				bodyPadding: 10,
				layout: {
					type: 'vbox',
					align: 'stretch'
				},
				defaults: {
					xtype: 'gtgrid',
					searchable: false,
					exportable: false,
					height: 400,
					margin: 5,
					columns: [{
						text: 'ID',
						dataIndex: 'id',
						flex: 1
					},{
						text: 'Nome',
						dataIndex: 'name',
						flex: 1
					}]
				},
				items: [{
					title: 'Transações',
					removeHandler: function (btn) {
						var grid = btn.up('gtgrid');
						var selection = grid.getSelectedRecords();
						
						if (selection.length == 0) {
							Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro.');
							return;
						}
						
						me.removeConflict(selection[0], 'transaction', grid);
					},
					store: storeTransactions2
				}]
			});
    	}
    	
    	config.items = [baseForm];
		
    	Ext.apply(me, config);
    	
    	me.callParent(arguments);
    	me.initConfig(config);
    },
    
    isUserConflict: function () {
    	var me = this;
    	
    	return me.conflictType == "Usuário";
    },
    
    removeConflict: function (record, type, grid) {
    	var me = this;
    	
		Ext.Msg.wait('Removendo...', 'Aguarde');
		Ext.Ajax.request({
			url: 'managers/tools/solveConflicts.jsp',
			params: {
				action: 'remove',
				origin: me.isUserConflict() ? 'user' : 'group',
				origin_id: me.isUserConflict() ? me.record.get('user_id') : me.record.get('group_id'),
				type: type,
				type_id: record.get('id'),
				conflict_id: me.record.get('conflict_id')
			},
			success: function (response) {
				var result = GeoTech.utils.prepareServerResponse(response);
				if (!result)
					return;
				
				grid.getStore().load({
					callback: function () {
						if (me.checkConflicts()) {
							Ext.Msg.confirm('Atenção!', 'O conflito foi resolvido. Deseja voltar a tela de seleção de conflitos?', function (answer) {
								if (answer == 'yes') {
									me.close();
									GTPlanner.app.activeTab.activeForm.getStore().load();
								}
							});
						}
						else {
							Ext.Msg.hide();
						}
					}
				});
			},
			failure: GeoTech.utils.prepareServerResponse
		});
    },
    
    checkConflicts: function () {
    	var me = this;
    	
    	var fs1 = me.down('fieldset');
    	var fs2 = fs1.nextSibling();
    	
    	var grid1 = fs1.down('gtgrid');
    	var grid2 = fs2.down('gtgrid');
    	
    	if (me.isUserConflict()) {
        	var grid3 = grid1.nextSibling();
        	var grid4 = grid2.nextSibling();
        	
        	return 	(grid1.getStore().getTotalCount() == 0 && grid3.getStore().getTotalCount() == 0) ||
        			(grid2.getStore().getTotalCount() == 0 && grid4.getStore().getTotalCount() == 0);
    	}
    	else {
    		return 	grid1.getStore().getTotalCount() == 0 || grid2.getStore().getTotalCount() == 0;
    	}
    }
});
