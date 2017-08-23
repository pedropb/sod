/*
 * ExtJS User Extension - GTReportPanel
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */

/*
 * Usage Example:
 * 
 * 
 */

Ext.define('Ext.ux.GTReportPanel', {
    extend: 'Ext.panel.Panel',
    alias: ['widget.gtreportpanel'],
    
    bodyPadding: '15px',
    
    layout: 'anchor',
    
    constructor: function (config) {
    	var me = this;
    	
    	config.completeLoad = (config.completeLoad != null ? config.completeLoad : true);
    	config.headerColumns = (config.headerColumns ? config.headerColumns : 2);
    	
    	var fields = config.fields;
    	if (!(fields instanceof Array)) {
    		console.log('GTReportPanel: Expected (Array) fields config parameter.');
    		return null;
    	}
    	
    	config.headerHeight = config.headerHeight ? config.headerHeight : 100;
    	config.gridHeight = config.gridHeight ? config.gridHeight : '-' + config.headerHeight;
    	
    	var headerCt = {
			xtype: 'container',
			itemId: 'headerCt',
			anchor: '100%',
			height: config.headerHeight,
			layout: 'column',
			items: []
    	};
    	
    	var header = headerCt.items;
		for (var i = 0; i < config.headerColumns; i++) {
			header.push({
				xtype: 'container',
				layout: 'anchor',
				columnWidth: parseFloat((1.0/config.headerColumns).toFixed(2)),
				items: []
			});
		}
		
    	for (var i=0; i<fields.length; i++) {
    		var j = i % config.headerColumns;
				
    		header[j].items.push(fields[i]);
    	}
    	
    	var grids = config.grids;
    	
    	var gridCt = {
			xtype: 'container',
			itemId: 'gridCt',
			anchor: '100% '+ config.gridHeight,
			layout: 'anchor',
    		margin: '15px 0 0 0',
    		defaults: {
    			xtype: 'gtgrid',
    			anchor: '100% ' + (100 / config.grids.length) + '%'
    		},
			items: []
    	};
    	
    	var reportBtn = {
        	text: 'Gerar Relatório',
            icon: 'images/page_white_text.png',
        	handler: function () {
				this.up('gtreportpanel').loadReport();
			}
        };
        
    	for (var i=0; i<grids.length; i++) {
    		var grid = grids[i];
    		
    		if (i > 0) {
    			grid.margin = '15px 0 0 0';
    		}
    		
    		if (grid.tbar instanceof Array) {
    			grid.tbar = [reportBtn,'-'].concat(grid.tbar);
    		}
    		else {
    			grid.tbar = [reportBtn];
    		}
    		
    		if (typeof(grid.title) != "string") {
    			grid.title = config.title;
    			grid.preventHeader = true;
    		}
    			
    		gridCt.items.push(grid);
    	}
    	
    	config.items = [headerCt, gridCt];
    	
    	Ext.apply(me, config);
    	
    	me.callParent(arguments);
        
    	me.initConfig(config);
    },
    
    afterRender: function () {
    	var me = this;
    	
    	var headerCt = me.getComponent('headerCt');
    	
    	for (var i = 0; i < headerCt.items.items.length; i++) {
			var header = headerCt.items.items[i];
			
			for (var j = 0; j < header.items.items.length; j++) {
				header.items.items[j].on('change', function () {
					me.loadReport();
				});
			}
		}
		
		me.callParent(arguments);
    },
    
    loadReport: function () {
    	var me = this;
    	
    	var headerCt = me.getComponent('headerCt');
    	
    	var params = {};
    	
    	var incomplete = false;
    	
    	for (var i = 0; i < headerCt.items.getCount(); i++) {
    		var ct = headerCt.items.getAt(i);
    		
    		for (var j=0; j<ct.items.getCount(); j++) {
    			var field = ct.items.getAt(j);
    			
    			if (field.paramName != null) {
    				if (field.isValid()) {
    					params[field.paramName] = field.getSubmitValue();
    				}
    				else {
    					incomplete = true;
    					break;
    				}
    			}	
    		}
    		
    		if (incomplete)
    			break;
    	}
    	
    	if (!incomplete || !me.completeLoad) {
    		var grids = me.getComponent('gridCt').query('grid');
    		
    		for (var i=0; i<grids.length; i++) {
    			var store = grids[i].getStore();
    			var proxy = store.getProxy();
    			proxy.extraParams = Ext.apply(proxy.extraParams, params);
    			store.load();
    		}	
    	}
    }
});