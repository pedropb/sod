/*
 * ExtJS User Extension - GTStore
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('Ext.ux.GTStore', {
    extend: 'Ext.data.Store',
    alias: ['widget.gtstore'],
    
    constructor: function(config) {
    	
    	if (!config)
    		config = {};

		var me = this;
		
		var parentId = null;
		if (GTPlanner && GTPlanner.app && GTPlanner.app.activeTab)
			parentId = GTPlanner.app.activeTab._id;
		
		var extraParams = {
			parentId: parentId
		};
		extraParams = Ext.apply(extraParams, config.extraParams);
		
		var proxyUrl = config.proxyUrl;
		if (proxyUrl)
			Ext.apply(me, {
				remoteSort: true,
				remoteFilter: true,
				buffered: config.noLimit ? false : true,
				autoLoad: false,
				pageSize: config.noLimit ? -1 : 1000,
				proxy: {
					type: 'ajax',
					url: proxyUrl,
					reader: {
						type: 'json',
						root: 'data',
						totalProperty: 'total'
					},
					timeout: 3600000,
					extraParams: extraParams
				}
			});
		
		me.callParent(arguments);
		
		me.initConfig(config);
	},
	
    
    initialize: function() {
    	var me = this;
    	me.clearFilter();
    	return me;
    },
    
    reload: function () {
    	var me = this;
    	
    	if (!me.lastOptions) {
    		me.lastOptions = {};
    		me.lastOptions.params = {};
    	}

    	me.load({
    		params: me.lastOptions.params
    	});
    },
    
    filter: function (filters) {
    	var me = this;
    	
		me.lastOptions = {
			params: {
				filter: filters
			}
		};
    	
        return me.callParent(arguments);
    },
    
    load: function(options) {
    	var me = this;
    	
    	me.lastOptions = options;
    	if (!me.lastOptions) {
    		me.lastOptions = {};
    		me.lastOptions.params = {};
    	}

        return me.callParent(arguments);
    },
    
    abort: function () {
    	if (this.isLoading()) {
    		Ext.Ajax.abort(this.proxy.activeRequest);
    		delete this.proxy.activeRequest;
    	}
    	
    	return this;
    }
});