/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.definitions.GroupsGrid', {
	extend: 'Ext.ux.GTGrid',
	alias: ['widget.groupsgrid'],
	
	title: 'Grupos',

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
	
	constructor: function (config) {
		var me = this;
		
		var user_id = config.user_id;
		var exclude_user_id = config.exclude_user_id;
		var exclude_groups = config.exclude_groups;

		var extraParams = {};
		if (user_id != null) {
			extraParams = {
				user_id: user_id
			};
		}
		else if (exclude_user_id) {
			extraParams = {
				exclude_user_id: exclude_user_id
			};
		}
		else if (exclude_groups) {
			extraParams = {
				exclude_groups: exclude_groups
			};
		}
		
		var filter_activities = config.filter_activities;
		if (filter_activities) {
			if (!extraParams)
				extraParams = {};
			
			extraParams.filter_activities = filter_activities;
		}

		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.groups);
		config.store.getProxy().extraParams = extraParams;
		config.store.load();
		
		var permissions = config.permissions ? config.permissions : {};
		config.tbar = config.tbar instanceof Array ? config.tbar : new Array();
		var needsSeparator = false;
		
		if (permissions.add) {
			if (user_id != null) {
				config.addHandler = function () {
					Ext.create('Ext.window.Window', {
						title: 'Adicionar Usuário aos Grupos',
						layout: 'fit',
						width: 600,
						height: 400,
						items: [{
							xtype: 'groupsgrid',
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
								var grid = win.down('groupsgrid');
								
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
								
								Ext.Msg.wait('Adicionando usuário aos grupos....', 'Aguarde');
								Ext.Ajax.request({
									url: 'managers/definitions/users.jsp',
									params: {
										action: 'addGroups',
										groups: ids,
										user: user_id
									},
									
									success: function (response) {
										var result = GeoTech.utils.prepareServerResponse(response);
										if (!result)
											return;
										
										Ext.Msg.hide();
										GeoTech.utils.msg('Sucesso', 'Usuário adicionado aos grupos com sucesso');
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
				config.addWindow = 'GTPlanner.definitions.GroupsWindow';
				
			}
			
			needsSeparator = true;
		}
			
		if (permissions.edit) {
			config.editWindow = 'GTPlanner.definitions.GroupsWindow';
			
			needsSeparator = true;
		}
			
		if (permissions.remove) {
			if (user_id != null) {
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
					
					Ext.Msg.wait('Removendo usuário dos grupos....', 'Aguarde');
					Ext.Ajax.request({
						url: 'managers/definitions/users.jsp',
						params: {
							action: 'removeGroups',
							groups: ids,
							user: user_id
						},
						
						success: function (response) {
							var result = GeoTech.utils.prepareServerResponse(response);
							if (!result)
								return;
							
							Ext.Msg.hide();
							GeoTech.utils.msg('Sucesso', 'Usuário removido dos grupos com sucesso');
							me.getStore().load();
						},
						failure: GeoTech.utils.prepareServerResponse
					});
				};
			}
			else {
				config.removeHandler = {
					url: 'managers/definitions/groups.jsp',
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
							group_id: record.get('id'),
							selModel: {
								mode: 'MULTI'
							}
						}]
					}).show();
				}
			});
			
			needsSeparator = true;
		}
		
		if (typeof(permissions.users) == "object") {
			if (needsSeparator)
				config.tbar.push('-');
			
			config.tbar.push({
				text: 'Usuários',
				icon: 'images/users.png',
				handler: function (btn) {
					var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione um registro.');
						return;
					}
					var record = selection[0];
					
					Ext.create('Ext.window.Window', {
						title: 'Usuários que pertencem ao grupo ' + record.get('name'),
						layout: 'fit',
						closable: true,
						width: 600,
						height: 400,
						items: [{
							xtype: 'usersgrid',
							preventHeader: true,
							permissions: permissions.users,
							group_id: record.get('id'),
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