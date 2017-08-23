/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.tools.SolveConflicts', {
	extend: 'Ext.ux.GTGrid',
	
	title: 'Resolução de Conflitos',

	columns: [{
		text     : 'ID Usuário',
		dataIndex: 'user_id',
		flex	 : 1,
		hidden	 : true
	},{
		text     : 'ID Grupo',
		dataIndex: 'group_id',
		flex	 : 1,
		hidden	 : true
	},{
		text     : 'Nome',
		dataIndex: 'name',
		flex	 : 1
	},{
		text     : 'Conflito',
		dataIndex: 'conflict',
		flex	 : 1
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
		xtype	 : 'checkcolumn',
		text	 : 'Aceito',
		dataIndex: 'accepted',
		width	 : 100
	}],
	
	tbarFilters: [{
		xtype: 'combo',
		fieldLabel: 'Organizar por',
		labelWidth: 80,
		margin: '0 0 0 10px',
		paramName: 'groupBy',
		store: ['Usuário', 'Grupo'],
		value: 'Usuário',
		editable: false
	}],
	
	constructor: function (config) {
		var me = this;
		
		var storeConfig = Ext.clone(GTPlanner.stores.solveConflicts);
		storeConfig.listeners = {
			beforeload: function (store, filters) {
				var sorters = store.getSorters();
				var proxy = store.getProxy();
				var target = proxy.extraParams.groupBy == "Usuário" ? "group_id" : "user_id";
				var fix = proxy.extraParams.groupBy == "Usuário" ? "user_id" : "group_id";
				
				for (var i = 0; i < sorters.length; i++) {
					if (sorters[i].property == target) {
						sorters[i].property = fix;
					}
				}
				
				return true;
			}
		};
		
		config.store = Ext.create('Ext.ux.GTStore',	storeConfig);
		config.store.getProxy().extraParams = {
			groupBy: 'Usuário'
		};
		config.store.initialize();
		
		var permissions = config.permissions ? config.permissions : {};
		
		config.tbar = new Array();
		
		if (permissions.solve) {
			config.tbar.push({
				text: 'Resolver conflito',
				icon: 'images/accept.png',
				handler: function (btn) {
					var selection = me.getSelectedRecords();

					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro.');
						return;
					}
					
					me.solveConflicts(selection[0]);
				}
			});
			
			config.tbar.push('-');
			
			config.dblClickHandler = function () {
				var selection = me.getSelectedRecords();

				me.solveConflicts(selection[0]);
			};
		}
		
		config.tbar.push({
			text: 'Visualizar motivo do aceite',
			icon: 'images/page_white_text.png',
			handler: function (btn) {
				var selection = me.getSelectedRecords();

				if (selection.length == 0) {
					Ext.Msg.alert('Atenção!', 'Selecione pelo menos um registro.');
					return;
				}
				
				var record = selection[0];
				if (!record.get('accepted')) {
					Ext.Msg.alert('Atenção!', 'Selecione um conflito que foi marcado como aceito.');
					return;
				}
				
				Ext.create('Ext.window.Window', {
					title: 'Motivo',
					layout: 'fit',
					closable: true,
					width: 500,
					height: 330,
					items: [{
						xtype: 'form',
						bodyPadding: 10,
						border: false,
						frame: true,
						layout: 'column',
						defaults: {
							readOnly: true,
							margin: 5,
							labelAlign: 'top',
							xtype: 'textfield',
							columnWidth: .5
						},
						items: [{
							fieldLabel: 'Usuário responsável',
							value: record.get('gt_user')
						},{
							fieldLabel: 'Data do motivo',
							value: record.get('reason_created')
						},{
    						fieldLabel: 'Motivo para a aceitação do conflito',
							columnWidth: 1,
							xtype: 'textarea',
							height: 200,
							value: record.get('reason')
						}]
					}]
				}).show();
			}
		});
		config.tbar.push('-');
		
		Ext.apply(me, config);

		me.callParent(arguments);
		me.initConfig(config);
	},
	
	solveConflicts: function (record) {
		var me = this;
		
		var cmb = me.down('combo[paramName=groupBy]');
		
		Ext.create('GTPlanner.tools.SolveConflictsWindow', {
			conflictType: cmb.getValue(),
			record: record
		}).show();
	}
});