/*
 * ExtJS User Extension - GTGridBox
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */

Ext.define('Ext.ux.GTGridBox', {
	extend: 'Ext.container.Container',
	alias: ['widget.gtgridbox'],
   
	padding: 0,
	
	constructor: function(config) {
		var me = this;
		
		config.layout= 'column';
		
		var width = config.width ? config.width : 300;
		var height = config.height ? config.height : 300;
						
		config.items = [{
			xtype: 'textfield',
			itemId: 'displayValue',
			columnWidth: 1,
			readOnly: true,
			disabled: config.disabled,
			labelAlign: config.labelAlign ? config.labelAlign : 'left',
			labelWidth: config.labelWidth ? config.labelWidth : 100,
			fieldLabel: config.fieldLabel ? config.fieldLabel : '',
			value: config.displayValue,
			allowBlank: config.allowBlank
		}, {
			xtype: 'component',
			hidden: config.readOnly,
			cls: 'x-border-box x-form-trigger x-gtgridbox-trigger',
			style: config.labelAlign == 'top' ? (Ext.isIE9 ? 'margin-top: 20px;' : (Ext.firefoxVersion > 0 ? 'margin-top: 21px;' : 'margin-top: 19px;')) : '',
			store: config.store,
			columns: config.columns,
			displayField: config.displayField,
			valueField: config.valueField ? config.valueField : config.displayField,
			listeners: {
				afterrender: function (btn) {
					btn.el.on('click', function () {
						var btn = this;
						
						var win = null;
						win= Ext.create('Ext.window.Window', {
							title: 'Selecione um registro',
							modal: true,
							width: width,
							height: height,
							layout: 'fit',
							items: [{
								xtype: 'gtgrid',
								border: false,
								bbar: [{
									text: 'Remover Seleção',
									hidden: !config.allowBlank,
									icon: 'images/cross.png',
									handler: function () {
										var gridbox = btn.up('container');
										gridbox.getComponent('displayValue').setValue('');
										
										var oldValue = gridbox.getComponent('value').getValue();
										var newValue = null;
										gridbox.getComponent('value').setRawValue(newValue);
										
										gridbox.fireEvent('change', gridbox, newValue, oldValue, null);
										gridbox.getComponent('value').fireEvent('change', gridbox, newValue, oldValue, null);
										
										win.close();
									}
								}],
								store: btn.store,
								columns: btn.columns,
								exportable: false,
								dblClickHandler: function (view, record) {
									var gridbox = btn.up('container');
									gridbox.getComponent('displayValue').setValue(record.get(btn.displayField));
									
									var oldValue = gridbox.getComponent('value').getValue();
									var newValue = record.get(btn.valueField);
									gridbox.getComponent('value').setRawValue(newValue);
									
									gridbox.fireEvent('change', gridbox, newValue, oldValue, record);
									gridbox.getComponent('value').fireEvent('change', gridbox, newValue, oldValue, record);
									
									win.close();
								}
							}]
						}).show();
						
						btn.store.initialize();
					}, btn);
				}
			}
		}, {
			xtype: 'hidden',
			name: config.name,
			itemId: 'value',
			value: config.value,
			disabled: config.disabled,
			allowBlank: config.allowBlank,
			listeners: config.listeners
		}];
		
		delete config.name;
		delete config.columns;
		delete config.store;
		delete config.displayField;
		delete config.valueField;
		delete config.value;
		delete config.displayValue;
		delete config.listeners;
		delete config.width;
		delete config.height;
		
		Ext.apply(me, config);
    	
		me.callParent(arguments);
		me.initConfig(config);
	},
	
	setValue: function (displayValue, value) {
		var me = this;
		
		if (value == null)
			value = displayValue;
		
		me.getComponent('displayValue').setValue(displayValue);
		me.getComponent('value').setValue(value);
	},
	
	setRawValue: function (displayValue, value) {
		var me = this;
		
		if (value == null)
			value = displayValue;
		
		me.getComponent('displayValue').setRawValue(displayValue);
		me.getComponent('value').setRawValue(value);
	},
	
	isValid: function () {
		var me = this;
		
		return me.getComponent('value').isValid();
	},
	
	getSubmitValue: function () {
		var me = this;
		
		return me.getComponent('value').getSubmitValue();
	},
	
	setDisabled: function (disabled) {
		var me = this;
		
		var items = me.items.items;
		for (var i = 0; i < items.length; i++) {
			items[i].setDisabled(disabled);
		}
		
		me.callParent(arguments);
	}
});