/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.reports.SolutionsGeneralGrid', {
	extend: 'Ext.ux.GTGrid',
	
	columns: [{
		text     : 'ID',
		dataIndex: 'target_id',
		flex	 : 3
	},{
		text     : 'Nome',
		dataIndex: 'name',
		flex	 : 3
	},{
		text     : 'Conflito',
		dataIndex: 'conflict',
		flex	 : 5
	},{
		text     : 'Atividade #1',
		dataIndex: 'activity1',
		flex	 : 1,
		hidden	 : true
	},{
		text     : 'Atividade #2',
		dataIndex: 'activity2',
		flex	 : 1,
		hidden	 : true
	},{
		text     : 'Descrição do aceite',
		dataIndex: 'description',
		flex	 : 10,
		renderer : function (v) {
			return v != null ? v.substring(0, 255) : "";
		}
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
	}],
	
	dblClickHandler: function () {
		var me = this;
		
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
				        margin: 5,
						readOnly: true,
						xtype: 'textfield'
				    },
			    	items: [{
				        fieldLabel: me.groupBy,
				        value: record.get('name'),
				        columnWidth: .4
				    },{
				        fieldLabel: 'Conflito',
				        value: record.get('conflict'),
				        columnWidth: .6
				    },{
				        fieldLabel: 'Responsável',
				        value: record.get('user'),
				        columnWidth: .4
				    },{
				        fieldLabel: 'Data',
				        value: Ext.Date.format(record.get('created'), 'd/m/Y H:i:s'),
				        columnWidth: .6
				    },{
				    	xtype: 'textarea',
				    	height: 100,
				    	fieldLabel: 'Descrição do Aceite',
				    	columnWidth: 1,
				    	value: record.get('description')
				    }]
			    }]
			}).show();
			
			Ext.getBody().unmask();
		}, 0);
	}, 
	
	constructor: function (config) {
		var me = this;
		
		if (!config.groupBy) {
			console.log("SolutionsGeneralGrid: groupBy parameters is required.");
			Ext.Error.raise('Required config parameter missing!');
		}
		
		me.columns[0].text = "ID " + config.groupBy;
		me.columns[1].text = config.groupBy;
		
		config.store = Ext.create('Ext.ux.GTStore',	GTPlanner.stores.solutionsGeneralReport);
		config.store.getProxy().extraParams = {
			groupBy: config.groupBy
		};
		config.store.initialize();
		
		config.title = 'Relatório de Aceites de ' + config.groupBy;
		
		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
	
});