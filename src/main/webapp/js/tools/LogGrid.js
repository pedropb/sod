/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.tools.Log', {
	extend: 'Ext.ux.GTGrid',
	
	title: 'Relatório de Alterações',

	columns: [{
		text     : '#',
		dataIndex: 'id',
		flex 	 : 1,
		hidden	 : true
	},{
		xtype    : 'datecolumn',
		text     : 'Data',
		dataIndex: 'created',
		format   : 'd/m/Y H:i:s',
		flex 	 : 3
	},{
		text     : 'Responsável',
		dataIndex: 'user',
		flex	 : 3
	},{
		text     : 'Módulo',
		dataIndex: 'module',
		flex	 : 3,
		hidden	 : true
	},{
		text     : 'Tela',
		dataIndex: 'form',
		flex	 : 3,
		hidden	 : true
	},{
		text     : 'Operação',
		dataIndex: 'operation',
		flex	 : 3,
		hidden	 : true
	},{
		text     : 'Descrição',
		dataIndex: 'description',
		flex	 : 10,
		renderer : function (v) {
			return v != null ? v.substring(0, 255) : "";
		}
	}],
	
	filters: [{
		name: 'created',
		label: 'Data',
		handler: {
			type:  'date'
		}
	},{
		name: 'user',
		label: 'Responsável',
		handler: {
			type:  'opentext'
		}
	},{
		name: 'module',
		label: 'Módulo',
		handler: {
			type:  'text',
			values: ['Definições', 'Ferramentas']
		}
	},{
		name: 'form',
		label: 'Tela',
		handler: {
			type:  'opentext'
		}
	},{
		name: 'operation',
		label: 'Operação',
		handler: {
			type:  'text',
			values: ['INSERT', 'UPDATE', 'DELETE']
		}
	},{
		name: 'description',
		label: 'Descrição',
		handler: {
			type:  'opentext'
		}
	}],
	
	constructor: function (config) {
		var me = this;
		
		if (!config)
			config = {};

		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.log);
		config.store.initialize();
		
		config.dblClickHandler = function () {
			var record = me.getSelectedRecords()[0];
			
			Ext.getBody().mask('Carregando registro...');
			
			setTimeout(function () {
				Ext.create('Ext.window.Window', {
					title: 'Detalhamento',
					modal: true,
					closable: true,
					width: 600,
					height: 300,
					layout: 'fit',
					items: [{
						xtype: 'form',
				    	border: false,
				    	frame: true,
				    	bodyPadding: 10,
				    	layout: {
				    		type: 'column',
				    		manageOverflow: false
				    	},
				    	autoScroll: true,
				    	defaults: {
					    	labelAlign: 'top',
					        columnWidth: .33,
					        margin: 5,
							readOnly: true,
							xtype: 'textfield'
					    },
				    	items: [{
					        fieldLabel: 'ID',
					        value: record.get('id')
					    },{
					        fieldLabel: 'Responsável',
					        value: record.get('user')
					    },{
					        fieldLabel: 'Data',
					        value: Ext.Date.format(record.get('created'), 'd/m/Y H:i:s')
					    },{
					        fieldLabel: 'Módulo',
					        value: record.get('module')
					    },{
					        fieldLabel: 'Tela',
					        value: record.get('form')
					    },{
					        fieldLabel: 'Operação',
					        value: record.get('operation')
					    },{
					    	xtype: 'textarea',
					    	height: 100,
					    	fieldLabel: 'Descrição',
					    	columnWidth: 1,
					    	value: record.get('description')
					    }]
				    }]
				}).show();
				
				Ext.getBody().unmask();
			}, 0);
		};
		
		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
});