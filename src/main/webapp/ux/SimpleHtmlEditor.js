Ext.define('Ext.ux.SimpleHtmlEditor', {
	extend: 'Ext.form.field.HtmlEditor',
	alias: ['widget.simplehtmleditor'],
	
	constructor: function (config) {
		var me = this;
		
		Ext.apply(me, {
			enableAlignments: false,
			enableColors: false,
			enableFont: false,
			enableFontSize: false,
			enableFormat: false,
			enableLinks: false,
			enableLists: false,
			enableSourceEdit: false,
			height: 80
		});
		
		me.callParent(arguments);
	},
	
	afterRender: function () {
		var me = this;
		me.getToolbar().hide();
	},
	
	isValid: function () {
		var me = this;
		
		if (!me.getValue())
			return false;
		
		var value = GeoTech.utils.removeHtmlTags(me.getValue());
		
		if (me.allowBlank === false && value.length == 0 && me.el && me.el.dom) {
			me.el.dom.firstChild.nextSibling.style.border = "1px solid red";
			return false;
		}
		else
			return true;
	},
	
	syncValue: function () {
		var me = this;
		
		if (me.el && me.el.dom)
			me.el.dom.firstChild.nextSibling.style.border = "1px solid #B5B8C8";
			
		me.callParent(arguments);
	},
	
	initFrameDoc: function() {
		var me = this,
            doc, task;

		if (me.el && me.el.dom)
			me.el.dom.firstChild.nextSibling.style.border = "1px solid #B5B8C8";
		
        Ext.TaskManager.stop(me.monitorTask);

        doc = me.getDoc();
        me.win = me.getWin();

        doc.open();
        doc.write(me.getDocMarkup());
        doc.close();

        task = null;
        task = { 
            run: function() {
                var doc;
                try {
                	doc = me.getDoc();
                	if (doc.body || doc.readyState === 'complete') {
                        Ext.TaskManager.stop(task);
                        me.setDesignMode(true);
                        Ext.defer(me.initEditor, 10, me);
                    }
                }
                catch (ex) {
                	Ext.TaskManager.stop(task);
                }
            },
            interval : 10,
            duration:10000,
            scope: me
        };
        Ext.TaskManager.start(task);
    }
});