/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.tools.CreateUsersWindow', {
    extend: 'Ext.ux.GTWizardWindow',
    
    closable: true,
    closeAction: 'destroy',
    modal: true,
    
    title: 'Assistente para criação de usuário',
    
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
    		instructions: 'Informe o ID e o Nome do novo usuário'
    	},{
	        xtype: 'uppertextfield',
	        fieldLabel: 'ID',
	        id: 'id',
	        name: 'user_id',
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
	    			win.user_id = card.down('textfield[name=user_id]').getValue();
	    			win.user_name = card.down('textfield[name=name]').getValue();
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
    		    '- Selecione as atividades que o usuário poderá executar',
    		    '- O sistema informará automaticamente atividades que estão em conflito'
    		],
    	},{
    		xtype: 'gtgrid',
    		margin: '10px 0 0 0',
    		id: 'UserActivitiesGrid',
    		title: 'Atividades executadas pelo usuário',
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
    		    	var parentGrid = Ext.getCmp('UserActivitiesGrid');
    		    	
    		    	var ids = me.getIdsArray(); 
    		    	
    		    	Ext.Msg.wait('Checando conflitos...', 'Aguarde');
					Ext.Ajax.request({
						url: 'managers/tools/createUsers.jsp',
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
            				
            				var userGroupsGrid = Ext.getCmp('UserGroupsGrid');
            	    		if (userGroupsGrid.getStore().getCount() > 0) {
            	    			Ext.Msg.confirm('Atenção!', 'Todos os grupos já adicionados serão removidos. Deseja continuar?', function (answer) {
            	    				if (answer == 'yes') {
            	    					targetStore.add(selection);
            	    					userGroupsGrid.getStore().removeAll();
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
				
				var userTransactionGrid = Ext.getCmp('UserTransactionsGrid');
				var userGroupsGrid = Ext.getCmp('UserGroupsGrid');
	    		if (userTransactionGrid.getStore().getCount() > 0 || userGroupsGrid.getStore().getCount() > 0) {
	    			Ext.Msg.confirm('Atenção!', 'Todas as transações e grupos já adicionadas também serão removidas. Deseja continuar?', function (answer) {
	    				if (answer == 'yes') {
	    					grid.getStore().remove(selection);
	    					userTransactionGrid.getStore().removeAll();
	    					userGroupsGrid.getStore().removeAll();
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
	    		var grid = Ext.getCmp('UserActivitiesGrid');
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
    		    '- Selecione as transações que o usuário poderá executar',
    		    '- As transações disponíveis já estão filtradas de acordo com as atividades selecionadas no passo anterior'
    		],
    	},{
    		xtype: 'gtgrid',
    		margin: '10px 0 0 0',
    		id: 'UserTransactionsGrid',
    		title: 'Transações executadas pelo usuário',
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
            	
            	var activitiesGrid = Ext.getCmp('UserActivitiesGrid');
            	
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
	    		var grid = Ext.getCmp('UserTransactionsGrid');
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
    		    '- Selecione os grupos que o usuário integrará',
    		    '- A listagem de grupos é filtrada automaticamente, exibindo apenas os grupos que não geram novos conflitos'
    		],
    	},{
    		xtype: 'gtgrid',
    		margin: '10px 0 0 0',
    		id: 'UserGroupsGrid',
    		title: 'Grupos que o usuário integrará',
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
            	
            	var activitiesGrid = Ext.getCmp('UserActivitiesGrid');
            	
            	Ext.create('Ext.window.Window', {
            		modal: true,
            		layout: 'fit',
            		width: 512,
            		height: 386,
            		title: 'Grupos',
            		items: [{
            			xtype: 'groupsgrid',
            			preventHeader: true,
            			exportable: false,
						selModel: {
							mode: 'MULTI'
						},
						filter_activities: activitiesGrid.getStore().getIdsArray(),
						exclude_groups: targetStore.getIdsArray()
            		}],
            		buttons: [{
            			text: 'Adicionar',
            			handler: function (btn) {
            				var win = btn.up('window');
            				var grid = win.down('groupsgrid');
            				
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
    	Ext.Msg.wait('Criando usuário...', 'Aguarde');
    	Ext.Ajax.request({
			url: 'managers/tools/createUsers.jsp',
			params: {
				action: 'create',
				groups: Ext.getCmp('UserGroupsGrid').getStore().getIdsArray(),
				transactions: Ext.getCmp('UserTransactionsGrid').getStore().getIdsArray(),
				name: Ext.getCmp('name').getValue(),
				id: Ext.getCmp('id').getValue()
			},
			success: function (response) {
				var result = GeoTech.utils.prepareServerResponse(response);
				if (!result)
					return;
				
				Ext.Msg.hide();
				win.close();
				GeoTech.utils.msg('Sucesso', 'Usuário criado com sucesso');
				GTPlanner.app.activeTab.activeForm.getStore().load();
			},
			failure: GeoTech.utils.prepareServerResponse
		});
    },
    
    listeners: {
    	beforeshow: function (win) {
    		var userActivitiesStore = Ext.getCmp('UserActivitiesGrid').getStore();
    		var userGroupsStore = Ext.getCmp('UserGroupsGrid').getStore();
        	var userTransactionsStore = Ext.getCmp('UserTransactionsGrid').getStore();
        	userActivitiesStore.removeAll();
        	userGroupsStore.removeAll();
			userTransactionsStore.removeAll();
    	}
    }
});
