/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.definitions.ConflictsGrid', {
	extend: 'Ext.ux.GTGrid',
	alias: ['widget.conflictsgrid'],
	
	title: 'Conflitos',

	columns: [{
		text     : 'ID',
		dataIndex: 'id',
		flex	 : 1
	},{
		text     : 'Nome',
		dataIndex: 'name',
		flex	 : 3
	},{
		text     : 'ID Ativ. #1',
		dataIndex: 'activity1_id',
		flex	 : 1,
		hidden	 : true
	},{
		text     : 'Atividade #1',
		dataIndex: 'activity1',
		flex	 : 3
	},{
		text     : 'ID Ativ. #2',
		dataIndex: 'activity2_id',
		flex	 : 1,
		hidden	 : true
	},{
		text     : 'Atividade #2',
		dataIndex: 'activity2',
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

		var activity_id = config.activity_id;

		var extraParams = {};
		if (activity_id != null) {
			extraParams = {
				activity_id: activity_id
			};
		}
		
		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.conflicts);
		config.store.getProxy().extraParams = extraParams;
		config.store.initialize();
		
		var permissions = config.permissions ? config.permissions : {};
		config.tbar = new Array();
		
		if (permissions.add) {
			config.addWindow = 'GTPlanner.definitions.ConflictsWindow';
		}
			
		if (permissions.edit) {
			config.editWindow = 'GTPlanner.definitions.ConflictsWindow';
		}
		
		if (permissions.remove) {
			config.removeHandler = 'managers/definitions/conflicts.jsp';
		}
		
		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
});