<%@page import="java.io.StringWriter"%>
<%@page import="org.json.JSONWriter"%>
<%@page import="geotech.Permissions"%><%@ page language="java" contentType="text/javascript; charset=UTF-8" pageEncoding="UTF-8"%>
Ext.namespace('GTPlanner');

GTPlanner = function () {
	var permissions = null;
<%
	StringWriter writer = new StringWriter();	
	JSONWriter output = new JSONWriter(writer);
	output.object();
	output.key("definitions").value(Permissions.canReadGroup(session, 2));
	output.key("tools").value(Permissions.canReadGroup(session, 3));
	output.key("dashboard").value(Permissions.canReadGroup(session, 4));
	output.key("reports").value(Permissions.canReadGroup(session, 5));
	output.endObject();
	out.println("permissions = " + writer + ";");
%>
	var menu = [];
	
	if (permissions.definitions)
		menu.push({
			xtype: 'gtmenuitem',
			title: 'Definições',
			icon: 'images/definitions.png',
			description: ['Usuários', 'Atividades', 'Grupos', 'Conflitos', 'Transações', 'Módulos', 'Importação de dados', 'Exportação de dados'],
			handler: function (event, el) {
				GTPlanner.app.loadTab('definitions');
			}
		});
	
	if (permissions.tools)
		menu.push({
			xtype: 'gtmenuitem',
			title: 'Ferramentas',
			icon: 'images/tools.png',
			description: ['Snapshots', 'Criar Grupos', 'Solucionar Conflitos', 'Criar Usuários', 'Rel. de Alterações', 'Consolidação dos dados', 'Solicitações de Acesso'],
			handler: function (event, el) {
				GTPlanner.app.loadTab('tools');
			}
		});
	
	if (permissions.dashboard)
		menu.push({
			xtype: 'gtmenuitem',
			title: 'Acompanhamento',
			icon: 'images/dashboard.png',
			descriptionColumns: 1,
			description: ['Gráficos de Evolução'],
			handler: function (event, el) {
				GTPlanner.app.loadTab('dashboard');
			}
		});
	
	if (permissions.reports)
		menu.push({
			xtype: 'gtmenuitem',
			title: 'Relatórios',
			icon: 'images/reports.png',
			description: ['Resumo', 'Dist. Usuários', 'Dist. Grupos', 'Dist. Módulos', 'Dist. Transações', 'Dist. Atividades', 'Dist. Conflitos', 'Rel. de Aceites'],
			handler: function (event, el) {
				GTPlanner.app.loadTab('reports');
			}
		});
		
	var menuContainer = [{
		xtype: 'container',
		flex: 1
	}];
	
	if (menu.length == 5) {
		menuContainer.push({
			xtype: 'container',
			layout: {
				type: 'table',
				columns: 3
			},
			items: [menu[0], menu[1], menu[2]]
		}, {
			xtype: 'container',
			layout: {
				type: 'table',
				columns: 2
			},
			items: [menu[3], menu[4]]
		});
	} else if (menu.length == 4) {
		menuContainer.push({
			xtype: 'container',
			layout: {
				type: 'table',
				columns: 2
			},
			items: [menu[0], menu[1]]
		}, {
			xtype: 'container',
			layout: {
				type: 'table',
				columns: 2
			},
			items: [menu[2], menu[3]]
		});
	} else if (menu.length == 3) {
		menuContainer.push({
			xtype: 'container',
			layout: {
				type: 'table',
				columns: 2
			},
			items: [menu[0], menu[1]]
		}, {
			xtype: 'container',
			layout: {
				type: 'table',
				columns: 1
			},
			items: [menu[2]]
		});
	} else if (menu.length == 2) {
		menuContainer.push({
			xtype: 'container',
			layout: {
				type: 'table',
				columns: 2
			},
			items: [menu[0], menu[1]]
		});
	} else if (menu.length == 1) {
		menuContainer.push({
			xtype: 'container',
			layout: {
				type: 'table',
				columns: 1
			},
			items: [menu[0]]
		});
	}
	
	menuContainer.push({
		xtype: 'container',
		flex: 1
	});
	
	var mainTab = Ext.create('Ext.panel.Panel', {
		title: 'Principal',
		_class: 'main',
		anchor: '100%',
		autoScroll: true,
		closable: false,
		layout: {
			type: 'vbox',
			align: 'center'
		},
		defaults: {
			animateClick: false
		},
		items: menuContainer
	});

	return {
		app: null,
		
		tabs: {
			'main': {
				constructor: function (params) {
					return mainTab;
				}
			}
		},
		
		forms: {},
		
		stores: {},
		
		reports: {},

		init: function () {
			var me = this;
			me.app = Ext.create('Ext.ux.GTTabbedApp', {
				logoLink: false,
				logoTitle: '',
				bannerHeight: 90,
				logoHeight: 50,
				iconsHeight: 40,
				iconsWidth: 40,
				initialTabs: [mainTab],
				icons: [{
					src: 'images/config.png',
					callback: function () {
						GTPlanner.app.loadTab('config');
					}
				}, {
					src: 'images/logout.png',
					callback: function () {
						GeoTech.utils.formSubmit({
							url: 'actions/login.jsp',
							params: {
								action: 'logout'
							}
						});
					}
				}]
			});
			
			me.app.loadHistory();
		},
		
		showErrorMessage: function (action) {
			GeoTech.utils.showErrorMessage(GTPlanner.app.activeTab.title, GTPlanner.app.activeTab.activeForm.title, action);
		}
	};
}();