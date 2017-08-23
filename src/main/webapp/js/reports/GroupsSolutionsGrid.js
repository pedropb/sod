/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.reports.GroupsSolutionsGrid', {
	extend: 'Ext.ux.GTGrid',
	
	title: 'Distribuição de Aceites de Grupos',

	columns: [{
		text     : 'ID',
		dataIndex: 'id',
		flex	 : 1
	},{
		text     : 'Nome',
		dataIndex: 'name',
		flex	 : 1
	},{
		text     : 'Quantidade',
		dataIndex: 'quantity',
		flex	 : 1
	}],
	
	tbarFilters: [{
		xtype: 'combo',
		fieldLabel: 'Agrupar por',
		labelWidth: 80,
		paramName: 'groupBy',
		store: ['Grupo', 'Módulo', 'Atividade', 'Transação', 'Conflito'],
		value: 'Grupo',
		editable: false
	}],
	
	tbar: [{
		text: 'Gráfico',
		icon: 'images/chart.png',
		handler: function (btn) {
			var tbar = btn.ownerCt;
			var cmb = tbar.down('combo');
			
			var groupBy = cmb.getValue();
			
			var store = Ext.create('Ext.ux.GTStore', GTPlanner.stores.groupsSolutionsReportChart);
			store.getProxy().extraParams = {
				groupBy: groupBy,
				chart: true
			};
			
			var win = Ext.create('Ext.window.Window', {
				title: 'Gráfico: Distribuição de Aceites de Grupos por ' + groupBy + ' (09 maiores)',
				width: 800,
				height: 600,
				modal: true,
				layout: 'fit',
				items: [{
					items: [{
						xtype: 'gtpiechart',
					    store: store
		    		}]
				}]
			}).show();
			
			win.setLoading(true);
			store.load({
				callback: function () {
					win.setLoading(false);
				}
			});
		}
	}, '-'],
	
	constructor: function (config) {
		var me = this;
		
		config = {
			store: Ext.create('Ext.ux.GTStore',	GTPlanner.stores.groupsSolutionsReport)
		};
		config.store.getProxy().extraParams = {
			groupBy: 'Grupo'
		};
		config.store.initialize();
		
		config.dblClickHandler = function () {
			var selection = me.getSelectedRecords();
			
			var cmb = me.down('combo');
			var groupBy = cmb.getValue();
			
			var store = Ext.create('Ext.ux.GTStore', GTPlanner.stores.groupsSolutionsReportDetail);
			store.getProxy().extraParams = {
				groupBy: groupBy,
				detail: selection[0].get('id')
			};
			store.initialize();
			
			Ext.create('Ext.window.Window', {
				title: 'Detalhamento',
				width: 800,
				height: 600,
				modal: true,
				layout: 'fit',
				items: [{
					xtype: 'gtgrid',
				    store: store,
				    title: 'Detalhamento',
				    preventHeader: true,
				    columns: [{
						text     : 'ID Grupo',
						dataIndex: 'reference_id',
						flex	 : 1,
						hidden	 : true
					},{
						text     : 'Grupo',
						dataIndex: 'reference',
						flex	 : 3
					},{
						text     : 'ID Conflito',
						dataIndex: 'conflict_id',
						flex	 : 1,
						hidden	 : true
					},{
						text     : 'Conflito',
						dataIndex: 'conflict',
						flex	 : 3
					},{
						text     : 'ID Ativ. #1',
						dataIndex: 'activity1_id',
						flex	 : 1,
						hidden	 : true
					},{
						text     : 'Atividade #1',
						dataIndex: 'activity1',
						flex	 : 3,
						hidden	 : true
					},{
						text     : 'ID Ativ. #2',
						dataIndex: 'activity2_id',
						flex	 : 1,
						hidden	 : true
					},{
						text     : 'Atividade #2',
						dataIndex: 'activity2',
						flex	 : 3,
						hidden	 : true
					}]
	    		}]
			}).show();
		};
		
		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	}
});