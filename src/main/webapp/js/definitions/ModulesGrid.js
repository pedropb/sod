/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.definitions.ModulesGrid', {
	extend: 'Ext.ux.GTGrid',
	alias: ['widget.modulesgrid'],
	
	title: 'Módulos',

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
		flex 	 : 2
	}],
	
	constructor: function (config) {
		var me = this;

		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.modules);
		config.store.initialize();
		
		var permissions = config.permissions ? config.permissions : {};
		config.tbar = new Array();
		var needsSeparator = false;
		
		if (permissions.add) {
			config.addWindow = 'GTPlanner.definitions.ModulesWindow';
			needsSeparator = true;
		}
			
		if (permissions.edit) {
			config.editWindow = 'GTPlanner.definitions.ModulesWindow';
			needsSeparator = true;
		}
		
		if (permissions.remove) {
			config.removeHandler = 'managers/definitions/modules.jsp';
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
						title: 'Transações pertencentes ao módulo ' + record.get('name'),
						layout: 'fit',
						closable: true,
						width: 600,
						height: 400,
						items: [{
							xtype: 'transactionsgrid',
							preventHeader: true,
							module_id: record.get('id'),
							permissions: permissions.transactions,
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