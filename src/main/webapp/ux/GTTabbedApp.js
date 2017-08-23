/*
 * ExtJS User Extension - GTTabbedApp
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */

/*
 * Usage example:
 * 

Ext.create('Ext.ux.GTTabbedApp', {
	logoUrl: 'images/logo.png', 						// default value
	logoHeight: 64, 									// optional, set it if you want to center the logo vertically
	logoLink: 'http://www.pedrobaracho.com.br',		// default value
	logoTitle: 'Desenvolvido por Pedro Baracho',	// default value
	bannerUrl: 'images/banner.png',						// default value
	sloganUrl: 'images/slogan.png',						// default value
	bannerHeight: 64,									// default value
	initialTabs: [mainTab],								// optional
	iconsHeight: 30,									// default value
	iconsWidth: 30,										// default value
	iconsSpacing: 10,									// default value
	icons: [{											// optional
		src: 'images/calendar.png',
		callback: function () {
			alert('calendar');
		}
	},{
		src: 'images/calendar.png',
		callback: function () {
			alert('calendar2');
		}
	}],
	tabs: {								// required
		'main'	: function (params) {
			return mainTab;
		},
		'financial': financial,
		'customers'	: customers
	}
});


 */

Ext.define('Ext.ux.GTTabbedApp', {
	extend: 'Ext.Viewport',
	alias: ['widget.gttabbedapp'],
	
	bannerUrl: 'images/banner.png',
	sloganUrl: 'images/slogan.png',
	bannerHeight: 64,
	
	icons: [],
	iconsHeight: 30,
	iconsWidth: 30,
	iconsSpacing: 10,

	initComponent: function() {
		var me = this;
		
		for (var i = me.icons.length - 1; i >= 0; i--)
			if (!me.icons[i].src)
				me.icons.splice(i, 1);
		
		var ct = {
			xtype: 'container',
			layout: 'hbox',
			style: {
				position: 'relative',
				top: -(me.bannerHeight + me.iconsSpacing) + (me.bannerHeight - me.iconsHeight)/2 + 'px',
				left: '100%',
				'margin-left': -me.icons.length * (me.iconsWidth + me.iconsSpacing * 2) - 15 + 'px'
			},
			height: me.bannerHeight,
			items: []
		};
			
		for (var i=0; i < me.icons.length; i++) {
			ct.items.push({
				xtype: 'component',
				style: {
					cursor: 'pointer',
					margin: me.iconsSpacing + 'px'
				},
				autoEl: {
					tag: 'img',
					src: me.icons[i].src,
					width: me.iconsWidth,
					height: me.iconsHeight
				},
				listeners: {
					el: {
						click: me.icons[i].callback
					}
				}
			});
		}
		
		var items = [];
		
		if (me.logoUrl != null) {
			items.push({
				xtype: 'component',
				style: {
					top: (me.logoHeight ? (me.bannerHeight - me.logoHeight)/2 + 'px' : '5px'),
					left: '5px',
					position: 'fixed'
				},
				autoEl: me.logoLink === false ? {
					html: '<img src="' + me.logoUrl + '" title="'+ me.logoTitle +'" />'			
				} : {
					tag: 'a',
					href: me.logoLink,
					target: '_blank',
					html: '<img src="' + me.logoUrl + '" title="'+ me.logoTitle +'" />'
				}
			});
		}
		
		items.push({
			xtype: 'component',
			height: me.bannerHeight,
			width: '100%',
			style: 'text-align: center;',
			html: 	'<table style="width: 100%;"><tbody>' +
				  	'	<tr><td height="'+ me.bannerHeight +'">' +
				  	'		<img src="' + me.sloganUrl + '" />' +
				  	'	</td></tr>' +
				  	'</tbody></table>'
		});
		 
		items.push(ct);
		
		me.header = Ext.create('Ext.container.Container', {
			anchor: '100%',
			style: {
				margin: '0 auto',
				'background-image':'url(' + me.bannerUrl + ')',
				'background-size': '100% 100%',
				'background-repeat': 'no-repeat',
				height: me.bannerHeight + 'px',
				filter: 'progid:DXImageTransform.Microsoft.AlphaImageLoader(src="' + me.bannerUrl + '", sizingMethod="scale")',
				'-ms-filter': 'progid:DXImageTransform.Microsoft.AlphaImageLoader(src="' + me.bannerUrl + '", sizingMethod="scale")'
			},
			items: items
		});
		
		me.tabsManager = Ext.create('Ext.tab.Panel', {
			anchor: '100% -'+me.bannerHeight,
			id: 'main-tabs',
			activeTab: me.activeTab,
			items: me.initialTabs,
			tabChangeHandler: function (oldTab, newTab) {
				me.activeTab = newTab;
				me.addHistory();
		    }
		});

		me.mainContainer = Ext.create('Ext.container.Container', {
			layout: {
				type: 'anchor'
			},
			autoDestroy: true,
			style: { margin: '0 auto' },
			items: [ me.header, me.tabsManager]
		});

		Ext.apply(me, {
			layout: {
				type: 'fit'
			},
			autoDestroy: true,
			style: { margin: '0 auto' },
			items: [ me.mainContainer ]
		});
		
		me.callParent(arguments);
	},

	activeTab: null,
	
	/*
	 * Função para acessar uma aba já carregada.
	 */	
	getTab: function(tabClass, tabId) {
		var me = this;
		
		var n = me.tabsManager.items.items.length;
		for (var i = 0; i < n; i++) {
			var target = me.tabsManager.items.items[i];
			
			if (target._class == tabClass && target._id == tabId) {
				return target;
			}
		}
	},
	
	/*
	 * Função para carregamento das abas
	 */	
	loadTab: function(tabClass, tabId, autoLoadForm, callback) {
		var me = this;

		// checar se a tab já está carregada
		var needToCreateTab = true;
			
		var n = me.tabsManager.items.items.length;
		for (var i = 0; i < n; i++) {
			var target = me.tabsManager.items.items[i];
			
			if (target._class == tabClass && target._id == tabId) {
				// troca para a tab já carregada
				me.tabsManager.setActiveTab(i);
				me.activeTab = target;
				needToCreateTab = false;

				break;
			}
		}

		if (needToCreateTab) {
			var f = null;
			
			try {
				f = eval('GTPlanner.tabs.' + tabClass);
				if (!f.constructor) {
					console.log('GTTabbedApp: Aba "' + tabClass + '" não definiu um constructor.');
					throw '';
				}
				
			}
			catch (ex) {
				console.log('GTTabbedApp: Não foi possível carregar a aba "' + tabClass + '".');
				return false;
			}
			
			var loadFn = function (ajaxParams, tabId) {
				me.activeTab = me.tabsManager.add(f.constructor(ajaxParams));
				me.activeTab._class = tabClass;
				
				if (tabId && me.activeTab)
					me.activeTab._id = tabId;

				if (me.changingHistory) {
					me.tabsManager.un('tabchange', me.tabsManager.tabChangeHandler);
					me.tabsManager.setActiveTab(me.activeTab);
					me.tabsManager.on('tabchange', me.tabsManager.tabChangeHandler);
				}
				else {
					me.tabsManager.setActiveTab(me.activeTab);
					if (autoLoadForm) {
						me.activeTab.loadForm(autoLoadForm);
					}
					else {
						me.addHistory();
					} 
				}
				
				if (typeof(callback) == "function")
					callback();
			};
			
			
			if (typeof(f.formsUrl) == "string" && f.formsUrl.length > 0) {
				Ext.Msg.wait('Carregando...', 'Aguarde');
				
				Ext.Ajax.request({
					url: f.formsUrl,
					params: {
						tabId: tabId
					},
					success: function (response) {
						Ext.Msg.hide();
						try {
							var result = Ext.decode(response.responseText);
							
							loadFn(result, tabId);
						}
						catch (ex) {
							console.log('GTTabbedApp: Erro ao buscar permissões para a aba "' + tabClass + '".');
						}
					},
					failure: function (response) {
						console.log('GTTabbedApp: Erro ao buscar permissões para a aba "' + tabClass + '".');
					}
				});
			}
			else {
				loadFn(null, tabId);
			}
		}
		else {
			if (typeof(callback) == "function")
				callback();
		}
		
		return true;
	},
	
	historyTokenDelimiter: '|',
	
	addHistory: function () {
		var me = this;
		
		var tabClass	= '';
		var tabId		= '';
		var formClass	= '';
		
		if (me.activeTab) {
			tabClass = escape(me.activeTab._class);
			if (me.activeTab._id)
				tabId = me.activeTab._id;
				
			if (me.activeTab.activeForm)
				formClass = escape(me.activeTab.activeForm._class);
		}
		
		var oldToken = Ext.History.getToken();
		
		var newToken = tabClass + me.historyTokenDelimiter + tabId + me.historyTokenDelimiter + formClass;
		
	    if (oldToken === null || oldToken.indexOf(newToken) === -1 ) {
	    	Ext.History.un('change', me.changeHistory);
	    	Ext.History.add(newToken);
	    	Ext.History.on('change', me.changeHistory, me);
	    }   
	},
	
	changeHistory: function (token) {
		var me = this;
		
		me.tabsManager.un('tabchange', me.tabsManager.tabChangeHandler);
		me.changingHistory = true;
		
		if (token) {
        	var parts = token.split(me.historyTokenDelimiter);
            
    		var tabClass 		= '';
    		var tabId			= '';
    		var formClass		= '';
    		
        	for (var i=0; i < parts.length; i++) {
        		switch (i) {
        			case 0:
        				tabClass = unescape(parts[i]);
        				continue;
        			case 1:
        				try {
        					tabId = Ext.decode((parts[i] ? unescape(parts[i]) : 'null'));
        				}
        				catch (err) {
        					console.log('Erro ao carregar objeto JSON: '+unescape(parts[i]));
        				}
        				continue;
        			case 2:
        				formClass = unescape(parts[i]);
        				continue;
        		}
        	}
        	
        	if (tabClass && tabClass.length > 0) {
        		me.loadTab(tabClass, tabId, formClass);
        	}
        }
		else {
			me.loadTab('main', null, true);
		}
		
		me.tabsManager.on('tabchange', me.tabsManager.tabChangeHandler);
		me.changingHistory = false;
    },
	
	loadHistory: function () {
		var me = this;
		
		Ext.History.on('change', me.changeHistory, me);
		
		if (location.hash.length > 0) {
			Ext.History.fireEvent('change', location.hash.substring(1));
		}
	}
});