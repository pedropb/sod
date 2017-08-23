/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.tools.CreateGroupsWindow', {
    extend: 'Ext.ux.GTWizardWindow',
    
    closable: true,
    closeAction: 'destroy',
    modal: true,
    
    title: 'Assistente para criação de grupo',
    
    items: [{
		xtype: 'form',
    	border: false,
    	frame: true,
    	bodyPadding: 10,
    	width : 500,
        height: 200,
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
         			   var me = field.up('window');
         			   
	         		   if (event.keyCode == Ext.EventObject.ENTER)
	         			   me.nextCard();
         		   }
         	   }
			}
	    },
    	items: [{
    		xtype: 'gtinstructions',
    		instructions: 'Informe o ID e o Nome do novo grupo'
    	},{
	        xtype: 'uppertextfield',
	        fieldLabel: 'ID',
	        id: 'id',
	        name: 'group_id',
			allowBlank: false
	    },{
	        xtype: 'textfield',
	        fieldLabel: 'Nome',
	        id: 'name',
	        name: 'name'
		}],
	    listeners: {
	    	beforenext: function (card, win) {
	    		if (card.isValid()) {
	    			win.group_id = card.down('textfield[name=group_id]').getValue();
	    			win.group_name = card.down('textfield[name=name]').getValue();
	    			return true;
	    		}
	    		else {
	    			Ext.Msg.alert('Atenção!', 'Existem erros de preenchimento no formulário.');
	    			return false;
	    		}
	    	}
	    }
    },{
		xtype: 'form',
    	border: false,
    	frame: true,
    	width : 500,
        height: 325,
    	layout: {
    		type: 'vbox',
    		align: 'stretch'
    	},
    	autoScroll: true,
    	items: [{
    		xtype: 'gtinstructions',
    		padding: 10,
    		instructions: [
    		    '- Selecione as atividades que o grupo poderá executar',
    		    '- O sistema informará automaticamente atividades que estão em conflito'
    		],
    	},{
    		xtype: 'gtgrid',
    		margin: '10px 0 0 0',
    		id: 'GroupActivitiesGrid',
    		title: 'Atividades executadas pelo grupo',
    		exportable: false,
    		searchable: false,
    		conflicts: [],
    		flex: 1,
    		tbar: ['->'],
    		showConflictsNotification: function () {
    			var me = this;
    			
    			var tb = me.getDockedItems('toolbar[dock=top]')[0];
    			if (!tb.down('button[text=Atividades em Conflitos]')) {
    				tb.add({
    					xtype: 'button',
    					text: 'Atividades em Conflitos',
    					icon: 'images/conflicts.png',
    					handler: function (btn) {
    						Ext.create('Ext.window.Window', {
    							modal: true,
    							closable: true,

    							title: 'Conflitos existentes',
    							
    							layout: 'fit',
    							
    							width: 400,
    							height: 200,
    							bodyPadding: 10,
    							
    							items: [{
    								xtype: 'textarea',
    								readOnly: true,
    								value: me.conflicts.join('\n')
    							}]
    						}).show();
    					}
    				});
    			}
    		},
    		hideConflictsNotification: function () {
    			var me = this;
    			
    			var tb = me.getDockedItems('toolbar[dock=top]')[0];
    			var btn = tb.down('button[text=Atividades em Conflitos]');
    			if (btn) {
    				tb.remove(btn);
    			}
    		},
    		store: Ext.create('Ext.data.Store', {
    			model: 'ActivityModel',
    			data: [],
    		    proxy: {
    		        type: 'memory',
    		    },
    		    autoLoad: true,
    		    getIdsArray: function () {
    		    	var me = this;
    		    	
    		    	var records = me.data;
    		    	var ids = new Array();
    		    	records.each(function (item) {
    		    		ids.push(item.get('id'));
    		    	});
    		    	
    		    	return ids.join('@@');
    		    },
    		    checkConflicts: function () {
    		    	var me = this;
    		    	var parentGrid = Ext.getCmp('GroupActivitiesGrid');
    		    	
    		    	var ids = me.getIdsArray(); 
    		    	
    		    	Ext.Msg.wait('Checando conflitos...', 'Aguarde');
					Ext.Ajax.request({
						url: 'managers/tools/createGroups.jsp',
						params: {
							action: 'checkActivityConflict',
							ids: ids
						},
						success: function (response) {
							var result = GeoTech.utils.prepareServerResponse(response);
							if (!result)
								return;
							
							Ext.Msg.hide();
							parentGrid.conflicts = result.conflicts;
							if (result.hasConflicts) {
								parentGrid.showConflictsNotification();
							}
							else {
								parentGrid.hideConflictsNotification();
							}
						},
						failure: GeoTech.utils.prepareServerResponse
					});
    		    },
    		    listeners: {
    		    	bulkremove: function (store) {
    		    		store.checkConflicts();
    		    	},
    		    	add: function (store) {
    		    		store.checkConflicts();
    		    	}
    		    }
    		}),
    		columns: [{
    			text     : 'ID',
    			dataIndex: 'id',
    			flex	 : 1
    		},{
    			text     : 'Nome',
    			dataIndex: 'name',
    			flex	 : 3
    		}],
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
            		title: 'Atividades',
            		items: [{
            			xtype: 'activitiesgrid',
            			preventHeader: true,
            			exportable: false,
						selModel: {
							mode: 'MULTI'
						},
						exclude_activities_id: targetStore.getIdsArray()
            		}],
            		buttons: [{
            			text: 'Adicionar',
            			handler: function (btn) {
            				var win = btn.up('window');
            				var grid = win.down('activitiesgrid');
            				
            				var selection = grid.getSelectedRecords();
            				
            				if (selection.length == 0) {
            					Ext.Msg.alert('Atenção!', 'Selecione um registro.');
            					return;
            				}
            				
            				var groupUsersGrid = Ext.getCmp('GroupUsersGrid');
            	    		if (groupUsersGrid.getStore().getCount() > 0) {
            	    			Ext.Msg.confirm('Atenção!', 'Todos os usuários já adicionados serão removidos. Deseja continuar?', function (answer) {
            	    				if (answer == 'yes') {
            	    					targetStore.add(selection);
            	    					groupUsersGrid.getStore().removeAll();
                        				win.close();
            	    				}
            	    			});
            	    		}
            	    		else {
                				targetStore.add(selection);
                				win.close();
            	    		}
            			}
            		}]
            	}).show();
            },
            removeHandler: function (btn) {
            	var grid = btn.up('gtgrid');
				
				var selection = grid.getSelectedRecords();
				
				if (selection.length == 0) {
					Ext.Msg.alert('Atenção!', 'Selecione um registro.');
					return;
				}
				
				var groupTransactionGrid = Ext.getCmp('GroupTransactionsGrid');
				var groupUsersGrid = Ext.getCmp('GroupUsersGrid');
	    		if (groupTransactionGrid.getStore().getCount() > 0 || groupUsersGrid.getStore().getCount() > 0) {
	    			Ext.Msg.confirm('Atenção!', 'Todas as transações e usuários já adicionadas também serão removidas. Deseja continuar?', function (answer) {
	    				if (answer == 'yes') {
	    					grid.getStore().remove(selection);
	    					groupTransactionGrid.getStore().removeAll();
	    					groupUsersGrid.getStore().removeAll();
	    				}
	    			});
	    		}
	    		else {
	    			grid.getStore().remove(selection);
	    		}
            }
    	}],
	    listeners: {
	    	beforenext: function (card, win) {
	    		var grid = Ext.getCmp('GroupActivitiesGrid');
	    		if (grid.getStore().getCount() > 0)
	    			return true;
	    		else {
	    			Ext.Msg.alert('Atenção!', 'Adicione pelo menos uma atividade antes de continuar');
	    			return false;
	    		}
	    	}
	    }
    },{
		xtype: 'form',
    	border: false,
    	frame: true,
    	width : 500,
        height: 325,
    	layout: {
    		type: 'vbox',
    		align: 'stretch'
    	},
    	autoScroll: true,
    	items: [{
    		xtype: 'gtinstructions',
    		padding: 10,
    		instructions: [
    		    '- Selecione as transações que o grupo poderá executar',
    		    '- As transações disponíveis já estão filtradas de acordo com as atividades selecionadas no passo anterior'
    		],
    	},{
    		xtype: 'gtgrid',
    		margin: '10px 0 0 0',
    		id: 'GroupTransactionsGrid',
    		title: 'Transações executadas pelo grupo',
    		exportable: false,
    		searchable: false,
    		flex: 1,
    		tbar: ['->'],
    		store: Ext.create('Ext.data.Store', {
    			model: 'TransactionModel',
    			data: [],
    		    proxy: {
    		        type: 'memory',
    		    },
    		    autoLoad: true,
    		    getIdsArray: function () {
    		    	var me = this;
    		    	
    		    	var records = me.data;
    		    	var ids = new Array();
    		    	records.each(function (item) {
    		    		ids.push(item.get('id'));
    		    	});
    		    	
    		    	return ids.join('@@');
    		    }
    		}),
    		columns: [{
    			text     : 'ID',
    			dataIndex: 'id',
    			flex	 : 1
    		},{
    			text     : 'Nome',
    			dataIndex: 'name',
    			flex	 : 3
    		},{
    			text     : 'ID Ativ.',
    			dataIndex: 'activity_id',
    			flex	 : 1,
    			hidden	 : true
    		},{
    			text     : 'Atividade',
    			dataIndex: 'activity',
    			flex	 : 3
    		},{
    			xtype    : 'datecolumn',
    			text     : 'Data de criação',
    			dataIndex: 'created',
    			format   : 'd/m/Y',
    			flex 	 : 3,
    			hidden	 : true
    		}],
			selModel: {
				mode: 'MULTI'
			},
            addHandler: function (btn) {
            	var parentGrid = btn.up('gtgrid');
            	var targetStore = parentGrid.getStore();
            	
            	var activitiesGrid = Ext.getCmp('GroupActivitiesGrid');
            	
            	Ext.create('Ext.window.Window', {
            		modal: true,
            		layout: 'fit',
            		width: 512,
            		height: 386,
            		title: 'Transações',
            		items: [{
            			xtype: 'transactionsgrid',
            			preventHeader: true,
            			exportable: false,
						selModel: {
							mode: 'MULTI'
						},
						filter_activities: activitiesGrid.getStore().getIdsArray(),
						exclude_transactions: targetStore.getIdsArray()
            		}],
            		buttons: [{
            			text: 'Adicionar',
            			handler: function (btn) {
            				var win = btn.up('window');
            				var grid = win.down('transactionsgrid');
            				
            				var selection = grid.getSelectedRecords();
            				
            				if (selection.length == 0) {
            					Ext.Msg.alert('Atenção!', 'Selecione um registro.');
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
					Ext.Msg.alert('Atenção!', 'Selecione um registro.');
					return;
				}
				
				grid.getStore().remove(selection);
            }
    	}],
	    listeners: {
	    	beforenext: function (card, win) {
	    		var grid = Ext.getCmp('GroupTransactionsGrid');
	    		if (grid.getStore().getCount() > 0)
	    			return true;
	    		else {
	    			Ext.Msg.alert('Atenção!', 'Adicione pelo menos uma transação antes de continuar');
	    			return false;
	    		}
	    	}
	    }
    },{
		xtype: 'form',
    	border: false,
    	frame: true,
    	width : 500,
        height: 325,
    	layout: {
    		type: 'vbox',
    		align: 'stretch'
    	},
    	autoScroll: true,
    	items: [{
    		xtype: 'gtinstructions',
    		padding: 10,
    		instructions: [
    		    '- Selecione os usuários que farão parte do grupo',
    		    '- A listagem de usuários é filtrada automaticamente, exibindo apenas os usuários que não geram novos conflitos'
    		],
    	},{
    		xtype: 'gtgrid',
    		margin: '10px 0 0 0',
    		id: 'GroupUsersGrid',
    		title: 'Usuários pertencentes ao grupo',
    		exportable: false,
    		searchable: false,
    		flex: 1,
    		tbar: ['->'],
    		store: Ext.create('Ext.data.Store', {
    			model: 'UserModel',
    			data: [],
    		    proxy: {
    		        type: 'memory',
    		    },
    		    autoLoad: true,
    		    getIdsArray: function () {
    		    	var me = this;
    		    	
    		    	var records = me.data;
    		    	var ids = new Array();
    		    	records.each(function (item) {
    		    		ids.push(item.get('id'));
    		    	});
    		    	
    		    	return ids.join('@@');
    		    }
    		}),
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
			selModel: {
				mode: 'MULTI'
			},
            addHandler: function (btn) {
            	var parentGrid = btn.up('gtgrid');
            	var targetStore = parentGrid.getStore();
            	
            	var activitiesGrid = Ext.getCmp('GroupActivitiesGrid');
            	
            	Ext.create('Ext.window.Window', {
            		modal: true,
            		layout: 'fit',
            		width: 512,
            		height: 386,
            		title: 'Usuários',
            		items: [{
            			xtype: 'usersgrid',
            			preventHeader: true,
            			exportable: false,
						selModel: {
							mode: 'MULTI'
						},
						filter_activities: activitiesGrid.getStore().getIdsArray(),
						exclude_users: targetStore.getIdsArray()
            		}],
            		buttons: [{
            			text: 'Adicionar',
            			handler: function (btn) {
            				var win = btn.up('window');
            				var grid = win.down('usersgrid');
            				
            				var selection = grid.getSelectedRecords();
            				
            				if (selection.length == 0) {
            					Ext.Msg.alert('Atenção!', 'Selecione um registro.');
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
					Ext.Msg.alert('Atenção!', 'Selecione um registro.');
					return;
				}
				
				grid.getStore().remove(selection);
            }
    	}],
	    listeners: {
	    	beforenext: function (card, win) {
	    		return true;
	    	}
	    }
    }],
    
    finishFn: function (win) {
    	var groupUsersStore = Ext.getCmp('GroupUsersGrid').getStore();
    	var groupTransactionsStore = Ext.getCmp('GroupTransactionsGrid').getStore();
    	
    	Ext.Msg.wait('Criando grupo...', 'Aguarde');
    	Ext.Ajax.request({
			url: 'managers/tools/createGroups.jsp',
			params: {
				action: 'create',
				users: groupUsersStore.getIdsArray(),
				transactions: groupTransactionsStore.getIdsArray(),
				name: Ext.getCmp('name').getValue(),
				id: Ext.getCmp('id').getValue()
			},
			success: function (response) {
				var result = GeoTech.utils.prepareServerResponse(response);
				if (!result)
					return;
				
				Ext.Msg.hide();
				win.close();
				GeoTech.utils.msg('Sucesso', 'Grupo criado com sucesso');
				GTPlanner.app.activeTab.activeForm.getStore().load();
			},
			failure: GeoTech.utils.prepareServerResponse
		});
    },
    
    listeners: {
    	beforeshow: function (win) {
    		var groupActivitiesStore = Ext.getCmp('GroupActivitiesGrid').getStore();
    		var groupUsersStore = Ext.getCmp('GroupUsersGrid').getStore();
        	var groupTransactionsStore = Ext.getCmp('GroupTransactionsGrid').getStore();
        	groupActivitiesStore.removeAll();
        	groupUsersStore.removeAll();
			groupTransactionsStore.removeAll();
    	}
    }
});
