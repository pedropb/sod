/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.reports.SummaryGrid', {
	extend: 'Ext.ux.GTGrid',
	
	title: 'Resumo',

	columns: [{
		text     : 'Descrição',
		dataIndex: 'name',
		flex	 : 1
	},{
		text     : 'Total',
		dataIndex: 'quantity',
		flex	 : 1
	}],
	
	constructor: function (config) {
		var me = this;
		
		config = {
			store: Ext.create('Ext.ux.GTStore',	GTPlanner.stores.summaryReport)
		};
		config.store.initialize();
		
		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
});