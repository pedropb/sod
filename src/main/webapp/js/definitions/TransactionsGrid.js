/*
 * GTPlanner Component
 * Developed by Pedro Baracho
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.definitions.TransactionsGrid', {
	extend: 'Ext.ux.GTGrid',
	alias: ['widget.transactionsgrid'],

	title: 'Transações',

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
		flex 	 : 3
	}],
	
	addTransactionsToGroup: function (transactions, groupId, callback) {
		Ext.Msg.wait('Adicionando transações ao grupo....', 'Aguarde');
		Ext.Ajax.request({
			url: 'managers/definitions/groups.jsp',
			params: {
				action: 'addTransactions',
				transactions: transactions,
				group: groupId
			},

			success: function (response) {
				var result = GeoTech.utils.prepareServerResponse(response);
				if (!result)
					return;

				Ext.Msg.hide();
				GeoTech.utils.msg('Sucesso', 'Transações adicionadas ao grupo com sucesso');
				
				callback();
			},
			failure: GeoTech.utils.prepareServerResponse
		});
	},
	
	addTransactionsToUser: function (transactions, userId, callback) {
		Ext.Msg.wait('Adicionando transações ao usuário....', 'Aguarde');
		Ext.Ajax.request({
			url: 'managers/definitions/users.jsp',
			params: {
				action: 'addTransactions',
				transactions: transactions,
				user: userId
			},

			success: function (response) {
				var result = GeoTech.utils.prepareServerResponse(response);
				if (!result)
					return;

				Ext.Msg.hide();
				GeoTech.utils.msg('Sucesso', 'Transações adicionadas ao usuário com sucesso');
				
				callback();
			},
			failure: GeoTech.utils.prepareServerResponse
		});
	},

	constructor: function (config) {
		var me = this;

		var group_id = config.group_id;
		var exclude_group_id = config.exclude_group_id;
		var user_id = config.user_id;
		var exclude_user_id = config.exclude_user_id;
		var module_id = config.module_id;
		var exclude_module_id = config.exclude_module_id;
		var activity_id = config.activity_id;
		var exclude_activity_id = config.exclude_activity_id;
		var exclude_transactions = config.exclude_transactions;

		var extraParams = {};
		if (group_id != null) {
			extraParams = {
				group_id: group_id
			};
		}
		else if (exclude_group_id) {
			extraParams = {
				exclude_group_id: exclude_group_id
			};
		}
		else if (user_id) {
			extraParams = {
				user_id: user_id
			};

			config.columns = [{
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
				xtype	 : 'checkcolumn',
				text     : 'Transação do Usuário',
				dataIndex: 'user_transaction',
				flex	 : 3
			},{
				xtype    : 'datecolumn',
				text     : 'Data de criação',
				dataIndex: 'created',
				format   : 'd/m/Y',
				flex 	 : 3
			}];
		}
		else if (exclude_user_id) {
			extraParams = {
				exclude_user_id: exclude_user_id
			};
		}
		else if (module_id) {
			extraParams = {
				module_id: module_id
			};
		}
		else if (exclude_module_id) {
			extraParams = {
				exclude_module_id: exclude_module_id
			};
		}
		else if (activity_id) {
			extraParams = {
				activity_id: activity_id
			};

			config.visibleColumns = ['ID', 'Nome', 'Data de Criação'];
		}
		else if (exclude_activity_id) {
			extraParams = {
				exclude_activity_id: exclude_activity_id
			};
		}
		else if (exclude_transactions) {
			extraParams = {
				exclude_transactions: exclude_transactions
			};
		}

		var filter_activities = config.filter_activities;
		if (filter_activities) {
			if (!extraParams)
				extraParams = {};

			extraParams.filter_activities = filter_activities;
		}

		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.transactions);
		config.store.getProxy().extraParams = extraParams;
		config.store.initialize();

		var permissions = config.permissions ? config.permissions : {};
		config.tbar = new Array();

		if (permissions.add) {
			if (group_id != null) {
				config.addHandler = function () {
					Ext.create('Ext.window.Window', {
						title: 'Adicionar Transações ao Grupo',
						layout: 'fit',
						width: 600,
						height: 400,
						items: [{
							xtype: 'transactionsgrid',
							preventHeader: true,
							exclude_group_id: group_id,
							selModel: {
								mode: 'MULTI'
							}
						}],
						buttons: [{
							text: 'Adicionar',
							handler: function (btn) {
								var win = btn.up('window');
								var grid = win.down('transactionsgrid');

								var selection = grid.getSelectedRecords();
								if (selection.length == 0) {
									Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro');
									return;
								}

								var transactions = '';
								for (var i = 0; i < selection.length; i++) {
									transactions += selection[i].get('id');

									if (i < selection.length - 1)
										transactions += '@@';
								}
								
								Ext.Msg.wait('Verificando conflitos...', 'Aguarde');
								Ext.Ajax.request({
									url: 'actions/checkConflicts.jsp',
									params: {
										action: 'conflictsBetweenNewTransactionsAndGroup',
										transactions: transactions,
										group: group_id
									},
									success: function (response) {
										var result = GeoTech.utils.prepareServerResponse(response);
										if (!result)
											return;
										
										if (result.conflicts === 0) {
											me.addTransactionsToGroup(transactions, group_id, function () {
												me.getStore().load();
												win.close();
											});
										}
										else {	
											Ext.Msg.show({
											    title:'Conflitos encontrados!',
												msg: 'As transações selecionadas apresentam <b>' + result.conflicts + ' conflito(s)</b> com este grupo e com os usuários deste grupo.<br>' +
													 'Clique em <b>Detalhes</b> para saber mais.<br>' +
													 'Deseja continuar?',
											    buttons: Ext.Msg.YESNOCANCEL,
											    buttonText: {
											      cancel: 'Detalhes'
											    },
											    icon: Ext.Msg.QUESTION,
											    fn: function(btn, info, opt) {
											        if (btn === 'yes') {
											        	me.addTransactionsToGroup(transactions, group_id, function () {
															me.getStore().load();
															win.close();
														});
											        } 
											        else if (btn === 'cancel') { // botão detalhes
														Ext.create('Ext.window.Window', {
															title: 'Novos conflitos encontrados',
															layout: 'fit',
															closable: true,
															width: 705,
															height: 265,
															items: [{
																xtype: 'form',
																bodyPadding: 10,
																border: false,
																frame: true,
																layout: 'column',
																items: [{
																	readOnly: true,
																	margin: 5,
																	labelAlign: 'top',
																	columnWidth: 1,
																	xtype: 'textarea',
																	height: 200,
																	value: result.details
																}]
															}],
															listeners: {
																close: function () {
																	// ao fechar detalhes dos novos conflitos, reabrir a tela de confirmação.
																	Ext.Msg.show(opt);
																}
															}
														}).show();
											        }
											    }
											});
										}
									},
									failure: GeoTech.utils.prepareServerResponse
								});
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
			else if (user_id != null) {
				config.addHandler = function () {
					Ext.create('Ext.window.Window', {
						title: 'Adicionar Transações ao Usuário',
						layout: 'fit',
						width: 600,
						height: 400,
						items: [{
							xtype: 'transactionsgrid',
							preventHeader: true,
							exclude_user_id: user_id,
							selModel: {
								mode: 'MULTI'
							}
						}],
						buttons: [{
							text: 'Adicionar',
							handler: function (btn) {
								var win = btn.up('window');
								var grid = win.down('transactionsgrid');

								var selection = grid.getSelectedRecords();
								if (selection.length == 0) {
									Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro');
									return;
								}

								var transactions = '';
								for (var i = 0; i < selection.length; i++) {
									transactions += selection[i].get('id');

									if (i < selection.length - 1)
										transactions += '@@';
								}
								
								Ext.Msg.wait('Verificando conflitos...', 'Aguarde');
								Ext.Ajax.request({
									url: 'actions/checkConflicts.jsp',
									params: {
										action: 'conflictsBetweenNewTransactionsAndUser',
										transactions: transactions,
										user: user_id
									},
									success: function (response) {
										var result = GeoTech.utils.prepareServerResponse(response);
										if (!result)
											return;
										
										if (result.conflicts === 0) {
											me.addTransactionsToUser(transactions, user_id, function () {
												me.getStore().load();
												win.close();
											});
										}
										else {
											Ext.Msg.show({
											    title:'Conflitos encontrados!',
												msg: 'As transações selecionadas apresentam <b>' + result.conflicts + ' conflito(s)</b> com este usuário.<br>' +
													 'Clique em <b>Detalhes</b> para saber mais.<br>' +
													 'Deseja continuar?',
											    buttons: Ext.Msg.YESNOCANCEL,
											    buttonText: {
											      cancel: 'Detalhes'
											    },
											    icon: Ext.Msg.QUESTION,
											    fn: function(btn, info, opt) {
											        if (btn === 'yes') {
											        	me.addTransactionsToUser(transactions, user_id, function () {
															me.getStore().load();
															win.close();
														});
											        } 
											        else if (btn === 'cancel') { // botão detalhes
														Ext.create('Ext.window.Window', {
															title: 'Novos conflitos encontrados',
															layout: 'fit',
															closable: true,
															width: 705,
															height: 265,
															items: [{
																xtype: 'form',
																bodyPadding: 10,
																border: false,
																frame: true,
																layout: 'column',
																items: [{
																	readOnly: true,
																	margin: 5,
																	labelAlign: 'top',
																	columnWidth: 1,
																	xtype: 'textarea',
																	height: 200,
																	value: result.details
																}]
															}],
															listeners: {
																close: function () {
																	// ao fechar detalhes dos novos conflitos, reabrir a tela de confirmação.
																	Ext.Msg.show(opt);
																}
															}
														}).show();
											        }
											    }
											});
										}
									},
									failure: GeoTech.utils.prepareServerResponse
								});
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
			else if (module_id != null) {
				config.addHandler = function () {
					Ext.create('Ext.window.Window', {
						title: 'Adicionar Transações ao Módulo',
						layout: 'fit',
						width: 600,
						height: 400,
						items: [{
							xtype: 'transactionsgrid',
							preventHeader: true,
							exclude_module_id: module_id,
							selModel: {
								mode: 'MULTI'
							}
						}],
						buttons: [{
							text: 'Adicionar',
							handler: function (btn) {
								var win = btn.up('window');
								var grid = win.down('transactionsgrid');

								var selection = grid.getSelectedRecords();
								if (selection.length == 0) {
									Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro');
									return;
								}

								var ids = '';
								for (var i = 0; i < selection.length; i++) {
									ids += selection[i].get('id');

									if (i < selection.length - 1)
										ids += '@@';
								}

								Ext.Msg.wait('Adicionando transações ao módulo....', 'Aguarde');
								Ext.Ajax.request({
									url: 'managers/definitions/modules.jsp',
									params: {
										action: 'addTransactions',
										transactions: ids,
										module: module_id
									},

									success: function (response) {
										var result = GeoTech.utils.prepareServerResponse(response);
										if (!result)
											return;

										Ext.Msg.hide();
										GeoTech.utils.msg('Sucesso', 'Transações adicionadas ao módulo com sucesso');
										win.close();
										me.getStore().load();
									},
									failure: GeoTech.utils.prepareServerResponse
								});

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
			else if (activity_id != null) {
				config.addHandler = function () {
					Ext.create('Ext.window.Window', {
						title: 'Adicionar Transações à Atividade',
						layout: 'fit',
						width: 600,
						height: 400,
						items: [{
							xtype: 'transactionsgrid',
							preventHeader: true,
							exclude_activity_id: activity_id,
							visibleColumns: ['ID', 'Nome', 'ID Ativ.', 'Atividade'],
							selModel: {
								mode: 'MULTI'
							}
						}],
						buttons: [{
							text: 'Adicionar',
							handler: function (btn) {
								var win = btn.up('window');
								var grid = win.down('transactionsgrid');

								var selection = grid.getSelectedRecords();
								if (selection.length == 0) {
									Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro');
									return;
								}

								var ids = '';
								for (var i = 0; i < selection.length; i++) {
									ids += selection[i].get('id');

									if (i < selection.length - 1)
										ids += '@@';
								}

								Ext.Msg.wait('Adicionando transações à atividade....', 'Aguarde');
								Ext.Ajax.request({
									url: 'managers/definitions/activities.jsp',
									params: {
										action: 'addTransactions',
										transactions: ids,
										activity: activity_id
									},

									success: function (response) {
										var result = GeoTech.utils.prepareServerResponse(response);
										if (!result)
											return;

										Ext.Msg.hide();
										GeoTech.utils.msg('Sucesso', 'Transações adicionadas à atividade com sucesso');
										win.close();
										me.getStore().load();
									},
									failure: GeoTech.utils.prepareServerResponse
								});

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
			else {
				config.addWindow = 'GTPlanner.definitions.TransactionsWindow';
			}

		}

		if (permissions.edit) {
			config.editWindow = 'GTPlanner.definitions.TransactionsWindow';
		}

		if (permissions.remove) {
			if (group_id != null) {
				config.removeHandler = function () {
					var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro');
						return;
					}

					var ids = '';
					for (var i = 0; i < selection.length; i++) {
						ids += selection[i].get('id');

						if (i < selection.length - 1)
							ids += '@@';
					}

					Ext.Msg.wait('Removendo transações do grupo....', 'Aguarde');
					Ext.Ajax.request({
						url: 'managers/definitions/groups.jsp',
						params: {
							action: 'removeTransactions',
							transactions: ids,
							group: group_id
						},

						success: function (response) {
							var result = GeoTech.utils.prepareServerResponse(response);
							if (!result)
								return;

							Ext.Msg.hide();
							GeoTech.utils.msg('Sucesso', 'Transações removidas do grupo com sucesso');
							me.getStore().load();
						},
						failure: GeoTech.utils.prepareServerResponse
					});
				};
			}
			else if (user_id != null) {
				config.removeHandler = function () {
					Ext.Msg.wait('Removendo transações do usuário....', 'Aguarde');

					var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro');
						return;
					}

					var removalFn = function (user_id, ids) {
						Ext.Ajax.request({
							url: 'managers/definitions/users.jsp',
							params: {
								action: 'removeTransactions',
								transactions: ids,
								user: user_id
							},

							success: function (response) {
								var result = GeoTech.utils.prepareServerResponse(response);
								if (!result)
									return;

								Ext.Msg.hide();
								GeoTech.utils.msg('Sucesso', 'Transações removidas do usuário com sucesso');
								me.getStore().load();
							},
							failure: GeoTech.utils.prepareServerResponse
						});
					};

					var buildIds = function (startIds, startI) {
						var ids = startIds;
						var i = startI;
						var record;
						while (i < selection.length) {
							record = selection[i];

							if (!record.get('user_transaction')) {
								Ext.Msg.confirm(
									'Atenção!',
									'A seleção contem transações que pertencem a grupo(s) que o usuário faz parte e, portanto, não podem ser removidas.<br><br>' +
					                'Deseja continuar com a remoção das outras transações?',
					                function (answer) {
							        	if (answer == "yes") {
					                		Ext.Msg.wait('Removendo transações do usuário....', 'Aguarde');
				                			while (i < selection.length) {
				                				record = selection[i];

					                			if (!record.get('user_transaction')) {
					                				i++;
					    							continue;
					    						}

					    						ids += record.get('id');

					    						if (i < selection.length - 1)
					    							ids += '@@';

					    						i++;
					                		}

					                		removalFn(user_id, ids);
					                	}
									});
								return;
							}

							ids += record.get('id');

							if (i < selection.length - 1)
								ids += '@@';

							i++;
						}

						removalFn(user_id, ids);
					};

					buildIds('', 0);
				};
			}
			else if (module_id != null) {
				config.removeHandler = function () {
					var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro');
						return;
					}

					var ids = '';
					for (var i = 0; i < selection.length; i++) {
						ids += selection[i].get('id');

						if (i < selection.length - 1)
							ids += '@@';
					}

					Ext.Msg.wait('Removendo transações do módulo....', 'Aguarde');
					Ext.Ajax.request({
						url: 'managers/definitions/modules.jsp',
						params: {
							action: 'removeTransactions',
							transactions: ids,
							module: module_id
						},

						success: function (response) {
							var result = GeoTech.utils.prepareServerResponse(response);
							if (!result)
								return;

							Ext.Msg.hide();
							GeoTech.utils.msg('Sucesso', 'Transações removidas do módulo com sucesso');
							me.getStore().load();
						},
						failure: GeoTech.utils.prepareServerResponse
					});
				};
			}
			else if (activity_id != null) {
				config.removeHandler = function () {
					var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro');
						return;
					}

					var ids = '';
					for (var i = 0; i < selection.length; i++) {
						ids += selection[i].get('id');

						if (i < selection.length - 1)
							ids += '@@';
					}

					Ext.Msg.wait('Removendo transações da atividade....', 'Aguarde');
					Ext.Ajax.request({
						url: 'managers/definitions/activities.jsp',
						params: {
							action: 'removeTransactions',
							transactions: ids,
							activity: activity_id
						},

						success: function (response) {
							var result = GeoTech.utils.prepareServerResponse(response);
							if (!result)
								return;

							Ext.Msg.hide();
							GeoTech.utils.msg('Sucesso', 'Transações removidas da atividade com sucesso');
							me.getStore().load();
						},
						failure: GeoTech.utils.prepareServerResponse
					});
				};
			}
			else {
				config.removeHandler = {
					url: 'managers/definitions/transactions.jsp',
					checkConstraints: true
				};
			}
		}

		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
});
