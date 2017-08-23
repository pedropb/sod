/*
 * ExtJS User Extension - GTCheckboxField
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */

/*
 * Usage example:

Ext.create('Ext.ux.GTCheckboxField', {
	fieldConfig: {
		xtype: 'textfield',
		fieldLabel: 'Filter'
	}
});

 */
Ext.define('Ext.ux.GTCheckboxField', {
	extend: 'Ext.form.Panel',
	alias: ['widget.gtcheckboxfield'],

	layout: 'hbox',
	
	constructor: function(config) {
		var me = this;
		
		config.preventHeader = true;
		config.closable = false;
		delete config.title;
		
		
		me.initConfig(config);
		
		config.checked = (config.checked ? config.checked : false);
		config.fieldConfig.disabled = !config.checked;
		
		Ext.apply(me, {
			border: false,
			items: [{
				xtype: 'checkbox',
				itemId: 'checkbox',
				margin: '0 15px 0 0',
				checked: config.checked,
				listeners: {
					change: function(checkbox, newValue) {
						checkbox.nextNode().setDisabled(!newValue);
					}
				}
			},config.fieldConfig]
		});
		
		me.callParent(arguments);
	},
	
	getValue: function () {
		var me = this;
		
		if (me.getComponent('checkbox').getValue())
			return me.items.getAt(1).getValue();
		else
			return null;
	},
	
	setValue: function (value) {
		var me = this;
		
		var field = me.items.getAt(1);
		
		field.setValue(value);
		
		return me;
	}
});
