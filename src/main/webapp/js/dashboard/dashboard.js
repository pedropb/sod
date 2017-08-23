GTPlanner.tabs.dashboard = {
		formsUrl: 'forms/dashboard/dashboard.jsp',

	constructor: function (params) {
		var store = Ext.create('Ext.data.JsonStore', {
			fields: ['id', 'date', 'usersConflicts', 'usersResiduals', 'groupsConflicts', 'groupsResiduals'],
			data: params.data
		});
		
		var residualUserChart = Ext.create('Ext.chart.Chart', {
			animate: true,
			store: store,
			axes: [{
				type: 'Numeric',
				position: 'left',
				fields: ['usersConflicts', 'usersResiduals'],
				grid: true,
				minimum: 0
			}, {
				type: 'Category',
				position: 'bottom',
				fields: ['id']
			}],
		    legend: {
		        position: 'right'
		    },
			series: [{
				type: 'column',
				axis: 'bottom',
				highlight: true,
				tips: {
					trackMouse: true,
					renderer: function(storeItem, item) {
						if (item.yField == 'usersConflicts') {
							this.update(storeItem.get('usersConflicts'));
						}
						else {
							this.update(storeItem.get('usersResiduals'));
						}
					}
				},
		        showInLegend: true,
				xField: 'id',
				yField: ['usersConflicts', 'usersResiduals'],
				title: ['Conflitos', 'Residuais'],
				stacked: true
			}]
		});
		residualUserChart.themeAttrs.colors = ['#CD2626', '#EE7621'];
		
		var residualGroupChart = Ext.create('Ext.chart.Chart', {
			animate: true,
			store: store,
			axes: [{
				type: 'Numeric',
				position: 'left',
				fields: ['groupsConflicts', 'groupsResiduals'],
				grid: true,
				minimum: 0
			}, {
				type: 'Category',
				position: 'bottom',
				fields: ['id']
			}],
		    legend: {
		        position: 'right'
		    },
			series: [{
				type: 'column',
				axis: 'bottom',
				highlight: true,
				tips: {
					trackMouse: true,
					renderer: function(storeItem, item) {
						if (item.yField == 'groupsConflicts') {
							this.update(storeItem.get('groupsConflicts'));
						}
						else {
							this.update(storeItem.get('groupsResiduals'));
						}
					}
				},
		        showInLegend: true,
				xField: 'id',
				yField: ['groupsConflicts', 'groupsResiduals'],
				title: ['Conflitos', 'Residuais'],
				stacked: true
			}]
		});
		residualGroupChart.themeAttrs.colors = ['#CD2626', '#EE7621'];
		
		var conflictsUserChart = Ext.create('Ext.chart.Chart', {
			animate: true,
			store: store,
			axes: [{
				type: 'Numeric',
				position: 'left',
				fields: ['usersConflicts', 'usersResiduals'],
				grid: true,
				minimum: 0
			}, {
				type: 'Category',
				position: 'bottom',
				fields: ['id']
			}],
		    legend: {
		        position: 'right'
		    },
			series: [{
				type: 'line',
				axis: 'bottom',
				highlight: true,
				tips: {
					trackMouse: true,
					minWidth: 100,
					renderer: function(storeItem, item) {
						this.update(storeItem.get('usersConflicts') ? storeItem.get('usersConflicts') : '0');
					}
				},
		        showInLegend: true,
				xField: 'id',
				yField: 'usersConflicts',
				title: 'Conflitos'
			},{
				type: 'line',
				axis: 'bottom',
				highlight: true,
				tips: {
					trackMouse: true,
					renderer: function(storeItem, item) {
						this.update(storeItem.get('usersResiduals') ? storeItem.get('usersResiduals') : '0');
					}
				},
		        showInLegend: true,
				xField: 'id',
				yField: 'usersResiduals',
				title: 'Residuais'
			}]
		});
		
		conflictsGroupChart = Ext.create('Ext.chart.Chart', {
			animate: true,
			store: store,
			axes: [{
				type: 'Numeric',
				position: 'left',
				fields: ['groupsConflicts', 'groupsResiduals'],
				grid: true,
				minimum: 0
			}, {
				type: 'Category',
				position: 'bottom',
				fields: ['id']
			}],
		    legend: {
		        position: 'right'
		    },
			series: [{
				type: 'line',
				axis: 'bottom',
				highlight: true,
				tips: {
					trackMouse: true,
					renderer: function(storeItem, item) {
						this.update(storeItem.get('groupsConflicts') ? storeItem.get('groupsConflicts') : '0');
					}
				},
		        showInLegend: true,
				xField: 'id',
				yField: 'groupsConflicts',
				title: 'Conflitos'
			},{
				type: 'line',
				axis: 'bottom',
				highlight: true,
				tips: {
					trackMouse: true,
					renderer: function(storeItem, item) {
						this.update(storeItem.get('groupsResiduals') ? storeItem.get('groupsResiduals') : '0');
					}
				},
		        showInLegend: true,
				xField: 'id',
				yField: 'groupsResiduals',
				title: 'Residuais'
			}]
		});

		return  Ext.create('Ext.panel.Panel', {
			title: 'Acompanhamento',
			closable: true,
			layout: {
				type: 'hbox',
				align: 'stretch'
			},
			dataStore: store,
			defaults: {
				xtype: 'container'
			},
			items: [{
				flex: 1,
				layout: {
					type: 'vbox',
					align: 'stretch'
				},
				defaults: {
					padding: 10,
					flex: 1
				},
				items: [
				    Ext.create('GTPlanner.reports.SummaryGrid'),
				    Ext.create('GTPlanner.tools.SnapshotsGrid')
				]
			},{
				flex: 3,
				layout: {
					type: 'vbox',
					align: 'stretch'
				},
				defaults: {
					flex: 1,
					xtype: 'container'
				},
				items: [{
					layout: {
						type: 'hbox',
						align: 'stretch'
					},
					defaults: {
						margin: 10,
						flex: 1
					},
					items: [{
						title: 'Proporção de Conflitos Residuais por Usuários',
						layout: 'fit',
						bodyPadding: 10,
						items: residualUserChart
					},{
						title: 'Proporção de Conflitos Residuais por Grupos',
						layout: 'fit',
						bodyPadding: 10,
						items: residualGroupChart
					}]
				},{
					layout: {
						type: 'hbox',
						align: 'stretch'
					},
					defaults: {
						margin: 10,
						flex: 1
					},
					items: [{
						title: 'Evolução de Conflitos por Usuários',
						layout: 'fit',
						bodyPadding: 10,
						items: conflictsUserChart
					},{
						title: 'Evolução de Conflitos por Grupos',
						layout: 'fit',
						bodyPadding: 10,
						items: conflictsGroupChart
					}]
				}]
			}],
			listeners: {
				activate: function (panel) {
					if (panel.firstLoad) {
						Ext.Msg.wait('Carregando...', 'Aguarde');
						Ext.Ajax.request({
							url: 'forms/dashboard/dashboard.jsp',
							success: function (response) {
								var result = Ext.decode(response.responseText);
								if (!result)
									return;
								
								Ext.Msg.hide();
								panel.dataStore.loadData(result.data);
							},
							failure: GeoTech.utils.prepareServerResponse
						});
					}
					
					panel.firstLoad = true;
				}
			}
		});
	}
};