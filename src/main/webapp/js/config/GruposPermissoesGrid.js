/*
 * GTPlanner Component - GruposPermissoesGrid
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.grid.GruposPermissoes', {
	extend: 'Ext.ux.GTGrid',
	
	constructor: function (config) {
		var me = this;

		config.title = (config.title ? config.title : 'Grupos');
		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.gruposPermissoes);
		config.store.initialize();
		
		var ajaxParams = config.ajaxParams;
		var permissions = {};
		config.tbar = new Array();
		
		if (ajaxParams)
			permissions = ajaxParams.permissions;
		
		if (permissions.add) {
			config.addWindow = {
				url: 'managers/config/gruposPermissoes.jsp',
				window: 'GTPlanner.window.GruposPermissoes'
			};
		}
			
		if (permissions.edit) {
			config.editWindow = 'GTPlanner.window.GruposPermissoes';
		}
		
		if (permissions.remove) {
			config.removeHandler = {
				url: 'managers/config/gruposPermissoes.jsp',
				checkConstraints: true
			};
		}
		
		config.columns = [{
			text     : 'Grupo',
			sortable : true,
			dataIndex: 'grupo',
			flex: 1
		},{
			text     : 'Descrição',
			sortable : true,
			dataIndex: 'descricao',
			flex: 1
		}];

		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
});