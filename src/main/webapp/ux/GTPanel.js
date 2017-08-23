/*
 * ExtJS User Extension - GTPanel
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 * 
 * 
 * Config options:
 * - panelMenu: (Array) defines the side menu. Example:
 *		panelMenu: [{
 *			text: 'Menu Item #1', // label of item
 *			formId: 'formItem1',  // GTPlanner.forms.formId object with at least a constructor function defined
 *			group: 'First Menu'	  // label of the group, for a tree menu
 *		}]
 * 
 * - autoLoadForm: (String) the formId that will load automatically, when the panel is rendered 
 */

Ext.define('Ext.ux.GTPanel', {
	extend: 'Ext.panel.Panel',
	alias: ['widget.gtpanel'],
	
	formCtId: 'ct-form',
	closable: true,

	constructor: function(config) {

		var me = this;
		
		var menu = config.panelMenu;
		
		var groups = {
			root: new Array()
		};
		var items = new Array();
		if (menu instanceof Array) {
			for (var i=0; i<menu.length; i++) {
				var el = menu[i];

				if (typeof(el.leaf) != "boolean") {
					el.leaf = true;
				}

				if (!el.iconCls) {
					el.iconCls = 'x-tree-no-icon'; 
				}
				
				if (typeof(el.group) == "string") {
					if (groups[el.group] instanceof Array) {
						groups[el.group].push(el);
					}
					else {
						groups[el.group] = [el];
					}
				}
				else {
					groups.root.push(el);
				}
			}
			
			var finalMenu = new Array();
			
			for (var group in groups) {
				if (group == "root")
					continue;
				
				finalMenu.push({
					text: group,
					expanded: true,
					leaf: false,
					iconCls: 'x-tree-no-icon',
					children: groups[group]
				});
			}
			
			finalMenu = finalMenu.concat(groups.root);
			
			items.push({
				xtype: 'treepanel',
				title: 'Menu',
				region: 'west',
				itemId: 'menu',
				multiSelect: false,
				lines: false,
				store: Ext.create('Ext.data.TreeStore', {
					root: {
						expanded: true,
						children: finalMenu
					}
				}),
				rootVisible: false,
				width: 200,
				split: true,
				listeners: {
					itemclick: {
						fn: function (view, record) {
							var handler = record.raw;
							
							if (!handler.leaf)
								return;
							
							if (handler.itemClick)
								handler.itemClick(function () {
									me.loadForm(handler.formId, false);
								}, view, record);
							else
								me.loadForm(handler.formId, false);
						}
					}
				}
			});
		}

		items.push({
			// this is necessary because Layout border doesnt allow adding / removing components at runtime
			// see Notes section on http://docs.sencha.com/ext-js/4-0/#!/api/Ext.layout.container.Border for further info
			xtype:'container',
			layout: 'fit',
			defaults: {
				autoScroll: true,
				defaults: {
					minWidth: 800
				}
			},
			itemId: me.formCtId,
			items: config.items,
			region: 'center'
		});
		
		config.items = items;
		
		Ext.apply(me, {
			layout: {
				type: 'border'
			}
		});
		
		me.callParent(arguments);
		
		me.initConfig(config);
	},
	
	activeForm: null,

	/*
	 * Função para carregamento dos formulários
	 * 
	 * Parâmetros:
	 * 		formClass - (String or Boolean) Nome do formulário GTPlanner que será carregado
	 * 										"true" é um atalho para o primeiro formulário do menu lateral
	 */
	loadForm: function(formClass, ignoreHistory) {
		var me = this;
		
		//
		if (formClass === true) {
			var menu = me.getComponent('menu');
			if (menu) {
				menu.getStore().getRootNode().eachChild(function (item) {
					if (typeof(item.raw.formId) == "string") {
						formClass = item.raw.formId;
						return false;
					}
				});
			}
		}
		
		var formCt = me.getFormCt();

		if (me.activeForm) {
			formCt.remove(me.activeForm, true);
		}
		
		var f;
		try {
			f = eval('GTPlanner.forms.' + formClass);
			if (!f.constructor) {
				console.log('GTPanel: Form "' + formClass + '" não definiu um constructor.');
				throw '';
			}
		}
		catch (ex) {
			console.log('GTPanel: Não foi possível carregar o formulário GTPlanner.forms."' + formClass + '".');
			return false;
		}
		
		var loadFn = function (ajaxParams) {
			me.activeForm = formCt.add(f.constructor(ajaxParams));
			me.activeForm._class = formClass;
			
			if (me.activeForm.doLayout)
				me.activeForm.doLayout();
			
			// selecionando o form carregado no menu lateral
			var menu = me.getComponent('menu');
			menu.getStore().getRootNode().eachChild(function (item) {
				if (item.raw.formId == formClass) {
					menu.getSelectionModel().select(item);
					return false;
				}
			});
			
			var app = me.up('gttabbedapp');
			if (ignoreHistory !== true && app !== null && typeof(app.addHistory) == "function")
				app.addHistory();
		};
		
		if (typeof(f.formsUrl) == "string" && f.formsUrl.length > 0) {
			Ext.Msg.wait('Carregando...', 'Aguarde');
			
			Ext.Ajax.request({
				url: f.formsUrl,
				params: {
					tabId: GTPlanner.app.activeTab._id
				},
				success: function (response) {
					Ext.Msg.hide();
					var result = null;
					try {
						result = Ext.decode(response.responseText);
					}
					catch (ex) {
						console.log('GTPanel: Erro ao buscar permissões para o formulário "' + formClass + '".');
					}
					
					try {
						loadFn(result);
					}
					catch (ex) {
						console.log('GTPanel: Erro ao criar o formulário GTPlanner.forms.' + formClass);
					}
				},
				failure: function (response) {
					Ext.Msg.hide();
					console.log('GTPanel: Erro ao buscar permissões para o formulário "' + formClass + '".');
				}
			});
		}
		else {
			try {
				loadFn();
			}
			catch (ex) {
				console.log('GTPanel: Erro ao criar o formulário GTPlanner.forms.' + formClass);
			}
		}
		
		return true;
	},
	
	getFormCt: function() {
		var me = this;
		return me.getComponent(me.formCtId);
	}
});