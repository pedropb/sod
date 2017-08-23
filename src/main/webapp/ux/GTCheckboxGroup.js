/*
 * ExtJS User Extension - GTCheckboxGroup
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('Ext.ux.GTCheckboxGroup', {
	extend: 'Ext.form.Panel',
	alias: ['widget.gtcheckboxgroup'],
	
	checkAllString: 'Marcar todos',

	constructor: function(config) {
		var me = this;

		me.initConfig(config);
		
		Ext.apply(me, {
			border: false,
			autoScroll: true,
			items: [{
				xtype: 'button',
				text: me.checkAllString,
				margin: '0 0 15px 0',
				handler: function (btn) {
					var checkboxgroup = btn.nextNode();
					
					var checkboxes = checkboxgroup.items;
					var checkedCount = checkboxgroup.getChecked().length;
					var oldValue = checkboxgroup.getValue();
					
					if (checkedCount == checkboxes.getCount()) { // all checkboxes are checked
						// uncheck all
						checkboxes.each(function (checkbox) {
							checkbox.setRawValue(false);
						});
					}
					else {
						// check all
						checkboxes.each(function (checkbox) {
							checkbox.setRawValue(true);
						});
					}
					
					checkboxgroup.fireEvent('change', checkboxgroup, checkboxgroup.getValue(), oldValue);
				}
			},
			Ext.create('Ext.form.CheckboxGroup', config.checkboxGroupConfig)]
		});
		
		me.callParent(arguments);
	},
	
	getValue: function () {
		var me = this;
		
		var checkboxgroup = me.items.getAt(1);
		
		return checkboxgroup.getValue();
	},
	
	setValue: function (value) {
		var me = this;
		
		var checkboxgroup = me.items.getAt(1);
		
		checkboxgroup.setValue(value);
		
		return me;
	}
});
