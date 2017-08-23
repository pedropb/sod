/*
 * GTPlanner Component - UsuáriosGrid
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.grid.Usuarios', {
	extend: 'Ext.ux.GTGrid',
	alias: ['widget.gtusersgrid'],
	
	constructor: function (config) {
		var me = this;

		config.title = (config.title ? config.title : 'Usuários');
		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.usuarios);
		config.store.getProxy().extraParams = {
    		'filtroListaInativo': config.filtroListaInativo
    	};
    	
		config.store.initialize();
		
		var ajaxParams = config.ajaxParams;
		var permissions = {};
		config.tbar = new Array();
		
		if (ajaxParams)
			permissions = ajaxParams.permissions;
		
		if (permissions.add) {
			config.addWindow = {
				url: 'managers/config/usuarios.jsp',
				window: 'GTPlanner.window.Usuarios'
			};
		}
			
		if (permissions.edit) {
			config.editWindow = 'GTPlanner.window.Usuarios';
		}
		
		if (permissions.password) {
			if (permissions.add || permissions.edit)
				config.tbar.push('-');
			
			config.tbar.push({
				text: 'Alterar senha',
				icon: 'images/key.png',
				handler: function (btn) {
					var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione um usuário.');
						return;
					}
					var record = selection[0];
					
					Ext.create('GTPlanner.window.AlterarSenha', {
						admin: true,
						user_id: record.get('id')
					}).show();
				}
			});
		}
		
		if (permissions.add || permissions.edit || permissions.password)
			config.tbar.push('-');
		
		config.tbarFilters = [{
			xtype: 'checkbox',
			labelWidth: 140,
			fieldLabel: 'Mostrar todos os usuários',
			margin: '0 0 0 5',
			paramName: 'filtro'
		}];

		config.columns = [{
			text     : 'Login',
			sortable : true,
			dataIndex: 'login',
			flex	 : 1
		},{
			xtype	 : 'checkcolumn',
			text     : 'Ativo',
			sortable : true,
			dataIndex: 'ativo',
			width	 : 100
		}];

		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
});