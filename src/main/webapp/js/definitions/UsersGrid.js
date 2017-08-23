/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.definitions.UsersGrid', {
	extend: 'Ext.ux.GTGrid',
	alias: ['widget.usersgrid'],
	
	title: 'Usuários',

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
		flex 	 : 1
	}],
	
	addUsersToGroup: function (users, groupId, callback) {
		Ext.Msg.wait('Adicionando usuários ao grupo....', 'Aguarde');
		Ext.Ajax.request({
			url: 'managers/definitions/groups.jsp',
			params: {
				action: 'addUsers',
				users: users,
				group: groupId
			},
			
			success: function (response) {
				var result = GeoTech.utils.prepareServerResponse(response);
				if (!result)
					return;
				
				Ext.Msg.hide();
				GeoTech.utils.msg('Sucesso', 'Usuários adicionados ao grupo com sucesso');
				callback();
			},
			failure: GeoTech.utils.prepareServerResponse
		});
	},
	
	constructor: function (config) {
		var me = this;

		var group_id = config.group_id;
		var exclude_group_id = config.exclude_group_id;
		var exclude_users = config.exclude_users;

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
		else if (exclude_users) {
			extraParams = {
				exclude_users: exclude_users
			};
		}
		
		var filter_activities = config.filter_activities;
		if (filter_activities) {
			if (!extraParams)
				extraParams = {};
			
			extraParams.filter_activities = filter_activities;
		}
		
		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.users);
		config.store.getProxy().extraParams = extraParams;
		config.store.initialize();
		
		var permissions = config.permissions ? config.permissions : {};
		config.tbar = config.tbar instanceof Array ? config.tbar : new Array();
		var needsSeparator = false;
		
		if (permissions.add) {
			if (group_id != null) {
				config.addHandler = function () {
					Ext.create('Ext.window.Window', {
						title: 'Adicionar Usuários ao Grupo',
						layout: 'fit',
						width: 600,
						height: 400,
						items: [{
							xtype: 'usersgrid',
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
								var grid = win.down('usersgrid');
								
								var selection = grid.getSelectedRecords();
								if (selection.length == 0) {
									Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro');
									return;
								}
								
								var users = '';
								for (var i = 0; i < selection.length; i++) {
									users += selection[i].get('id');
									
									if (i < selection.length - 1)
										users += '@@';
								}
								
								Ext.Msg.wait('Verificando conflitos...', 'Aguarde');
								Ext.Ajax.request({
									url: 'actions/checkConflicts.jsp',
									params: {
										action: 'conflictsBetweenNewUsersAndGroup',
										users: users,
										group: group_id
									},
									success: function (response) {
										var result = GeoTech.utils.prepareServerResponse(response);
										if (!result)
											return;
										
										if (result.conflicts === 0) {
											me.addUsersToGroup(users, group_id, function () {
												me.getStore().load();
												win.close();
											});
										}
										else {	
											Ext.Msg.show({
											    title:'Conflitos encontrados!',
												msg: 'Os usuários selecionados apresentam <b>' + result.conflicts + ' conflito(s) com este grupo.</b><br>' +
													 'Clique em <b>Detalhes</b> para saber mais.<br>' +
													 'Deseja continuar?',
											    buttons: Ext.Msg.YESNOCANCEL,
											    buttonText: {
											      cancel: 'Detalhes'
											    },
											    icon: Ext.Msg.QUESTION,
											    fn: function(btn, info, opt) {
											        if (btn === 'yes') {
														me.addUsersToGroup(users, group_id, function () {
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
			else {
				config.addWindow = 'GTPlanner.definitions.UsersWindow';
			}
			
			needsSeparator = true;
		}
			
		if (permissions.edit) {
			config.editWindow = 'GTPlanner.definitions.UsersWindow';
			needsSeparator = true;
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
					
					Ext.Msg.wait('Removendo usuários do grupo....', 'Aguarde');
					Ext.Ajax.request({
						url: 'managers/definitions/groups.jsp',
						params: {
							action: 'removeUsers',
							users: ids,
							group: group_id
						},
						
						success: function (response) {
							var result = GeoTech.utils.prepareServerResponse(response);
							if (!result)
								return;
							
							Ext.Msg.hide();
							GeoTech.utils.msg('Sucesso', 'Usuários removidos do grupo com sucesso');
							me.getStore().load();
						},
						failure: GeoTech.utils.prepareServerResponse
					});
				};
			}
			else {
				config.removeHandler = {
					url: 'managers/definitions/users.jsp',
					checkConstraints: true
				};
			}
				
			needsSeparator = true;
		}
		
		if (config.tbar.length > 0)
			needsSeparator = true;
		
		if (typeof(permissions.transactions) == "object") {
			if (needsSeparator)
				config.tbar.push('-');
			
			config.tbar.push({
				text: 'Transações',
				icon: 'images/transactions.png',
				handler: function (btn) {
					var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione um registro.');
						return;
					}
					var record = selection[0];
					
					Ext.create('Ext.window.Window', {
						title: 'Transações realizadas por ' + record.get('name'),
						layout: 'fit',
						closable: true,
						width: 600,
						height: 400,
						items: [{
							xtype: 'transactionsgrid',
							preventHeader: true,
							permissions: permissions.transactions,
							user_id: record.get('id'),
							selModel: {
								mode: 'MULTI'
							}
						}]
					}).show();
				}
			});
			
			needsSeparator = true;
		}
		
		if (typeof(permissions.groups) == "object") {
			if (needsSeparator)
				config.tbar.push('-');
			
			config.tbar.push({
				text: 'Grupos',
				icon: 'images/users.png',
				handler: function (btn) {
					var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione um registro.');
						return;
					}
					var record = selection[0];
					
					Ext.create('Ext.window.Window', {
						title: 'Grupos que ' + record.get('name') + ' pertence',
						layout: 'fit',
						closable: true,
						width: 600,
						height: 400,
						items: [{
							xtype: 'groupsgrid',
							preventHeader: true,
							permissions: permissions.groups,
							user_id: record.get('id'),
							selModel: {
								mode: 'MULTI'
							}
						}]
					}).show();
				}
			});
			
			needsSeparator = true;
		}

		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
});