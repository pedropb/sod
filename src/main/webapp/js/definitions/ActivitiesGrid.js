/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.definitions.ActivitiesGrid', {
	extend: 'Ext.ux.GTGrid',
	alias: ['widget.activitiesgrid'],
	
	title: 'Atividades',

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

		var exclude_activities_id = config.exclude_activities_id;

		var extraParams = {};
		if (exclude_activities_id != null) {
			extraParams = {
				exclude_activities_id: exclude_activities_id
			};
		}

		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.activities);
		config.store.getProxy().extraParams = extraParams;
		config.store.initialize();
		
		var permissions = config.permissions ? config.permissions : {};
		config.tbar = new Array();
		var needsSeparator = false;
		
		if (permissions.add) {
			config.addWindow = 'GTPlanner.definitions.ActivitiesWindow';
			needsSeparator = true;
		}
			
		if (permissions.edit) {
			config.editWindow = 'GTPlanner.definitions.ActivitiesWindow';
			needsSeparator = true;
		}
		
		if (permissions.remove) {
			config.removeHandler = {
				url: 'managers/definitions/activities.jsp',
				checkConstraints: true
			};
				
			needsSeparator = true;
		}

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
						title: 'Transações pertencentes à atividade ' + record.get('name'),
						layout: 'fit',
						closable: true,
						width: 600,
						height: 400,
						items: [{
							xtype: 'transactionsgrid',
							preventHeader: true,
							permissions: permissions.transactions,
							activity_id: record.get('id'),
							selModel: {
								mode: 'MULTI'
							}
						}]
					}).show();
				}
			});
			
			needsSeparator = true;
		}
		
		if (permissions.conflicts) {
			if (needsSeparator)
				config.tbar.push('-');
			
			config.tbar.push({
				text: 'Conflitos',
				icon: 'images/conflicts.png',
				handler: function (btn) {
					var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione um registro.');
						return;
					}
					var record = selection[0];
					
					Ext.create('Ext.window.Window', {
						title: 'Conflitos envolvendo a atividade ' + record.get('name'),
						layout: 'fit',
						closable: true,
						width: 600,
						height: 400,
						items: [{
							xtype: 'conflictsgrid',
							preventHeader: true,
							visibleColumns: ['ID', 'Atividade #1', 'Atividade #2', 'Data de Criação'],
							activity_id: record.get('id')
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