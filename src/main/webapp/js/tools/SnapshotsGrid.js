/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.tools.SnapshotsGrid', {
	extend: 'Ext.ux.GTGrid',
	
	title: 'Snapshots',

	columns: [{
		text     : '#',
		dataIndex: 'id',
		flex 	 : 1
	},{
		xtype    : 'datecolumn',
		text     : 'Data',
		dataIndex: 'created',
		format   : 'd/m/Y',
		flex 	 : 3
	},{
		text     : 'Conflitos de Usuários',
		dataIndex: 'users_conflicts',
		flex	 : 3
	},{
		text     : 'Conflitos de Usuários Aceitos',
		dataIndex: 'accepted_users_conflicts',
		hidden	 : true,
		flex	 : 3
	},{
		text     : 'Conflitos de Grupos',
		dataIndex: 'groups_conflicts',
		flex	 : 3
	},{
		text     : 'Conflitos de Grupos Aceitos',
		dataIndex: 'accepted_groups_conflicts',
		hidden	 : true,
		flex	 : 3
	}],
	
	constructor: function (config) {
		var me = this;
		
		if (!config)
			config = {};

		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.snapshots);
		config.store.initialize();
		
		var permissions = config.permissions ? config.permissions : {};
		
		if (permissions.add) {
			config.addHandler = function () {
				Ext.Msg.wait('Gerando snapshot...', 'Aguarde');
				Ext.Ajax.request({
					url: 'managers/tools/snapshots.jsp',
					params: {
						action: 'add'
					},
					success: function (response) {
						var result = GeoTech.utils.prepareServerResponse(response);
						if (!result)
							return;
						
						Ext.Msg.hide();
						GeoTech.utils.msg('Sucesso', 'Snapshot gerado com sucesso');
						me.getStore().load();
					},
					failure: GeoTech.utils.prepareServerResponse
				});
			};
		}
			
		if (permissions.remove) {
			config.removeHandler = 'managers/tools/snapshots.jsp';
		}
		
		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
});