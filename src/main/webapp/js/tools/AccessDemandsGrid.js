/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.tools.AccessDemandsGrid', {
	extend: 'Ext.ux.GTGrid',
	
	title: 'Solicitações de Acesso',

	columns: [{
		text     : '#',
		dataIndex: 'id',
		flex 	 : 1
	},{
		text     : 'Status',
		dataIndex: 'status',
		flex	 : 3,
		renderer : function (val) {
			switch (val) {
			case 'Aprovado':
				return '<span style="color:green">Aprovado</span>';
			case 'Criado':
				return '<span style="color:green; font-weight:bold;">Criado</span>';
			case 'Negado':
				return '<span style="color:red">Negado</span>';
			default:
				return val;
			}
		}
	},{
		xtype    : 'datecolumn',
		text     : 'Data Criação',
		dataIndex: 'created',
		format   : 'd/m/Y H:i:s',
		flex 	 : 3
	},{
		text     : 'Solicitante',
		dataIndex: 'applicant',
		flex	 : 3
	},{
		text     : 'Nome Usuário',
		dataIndex: 'real_name',
		flex	 : 3
	},{
		text     : 'Usuário de Rede',
		dataIndex: 'user_name',
		flex	 : 3
	},{
		text     : 'Tipo',
		dataIndex: 'demand_type',
		flex	 : 3,
		hidden	 : true
	},{
		xtype    : 'datecolumn',
		text     : 'Data Aprovação',
		dataIndex: 'updated',
		format   : 'd/m/Y H:i:s',
		flex 	 : 3
	},{
		text     : 'Aprovador',
		dataIndex: 'approver',
		flex	 : 3
	}],
	
	filters: [{
		name: 'created',
		label: 'Data Criação',
		handler: {
			type:  'date'
		}
	},{
		name: 'user_name',
		label: 'Usuário de Rede',
		handler: {
			type:  'opentext'
		}
	},{
		name: 'applicant',
		label: 'Solicitante',
		handler: {
			type:  'opentext'
		}
	},{
		name: 'real_name',
		label: 'Nome Usuário',
		handler: {
			type:  'opentext'
		}
	},{
		name: 'approver',
		label: 'Aprovador',
		handler: {
			type:  'opentext'
		}
	},{
		name: 'demand_type',
		label: 'Tipo',
		handler: {
			type:  'text',
			values: GTPlanner.tools.ACCESS_DEMANDS_CONSTANTS.TYPES
		}
	},{
		name: 'status',
		label: 'Status',
		handler: {
			type:  'text',
			values: GTPlanner.tools.ACCESS_DEMANDS_CONSTANTS.STATUS
		}
	}],
	
	dblClickHandler: function () {
		var me = this;
		
		Ext.create('GTPlanner.tools.AccessDemandsWindow', {
			mode: (me.permissions && me.permissions.approve) ? 'approve' : 'read',
			store: me.getStore(),
			record: me.getSelectedRecords()[0]
		}).show();
	},
	
	initComponent: function () {
		var me = this;
		
		me.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.accessDemands);
		me.store.initialize();
		
		me.callParent(arguments);
	}
	
});