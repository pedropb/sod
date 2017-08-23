// Array.indexOf implementation for older browsers
if(!Array.prototype.indexOf){Array.prototype.indexOf=function(searchElement){"use strict";if(this==null){throw new TypeError();} var t=Object(this);var len=t.length>>>0;if(len===0){return-1;} var n=0;if(arguments.length>0){n=Number(arguments[1]);if(n!=n){n=0;}else if(n!=0&&n!=Infinity&&n!=-Infinity){n=(n>0||-1)*Math.floor(Math.abs(n));}} if(n>=len){return-1;} var k=n>=0?n:Math.max(len-Math.abs(n),0);for(;k<len;k++){if(k in t&&t[k]===searchElement){return k;}} return-1;};}

/*
 * ExtJS User Extension - GTFilterWindow
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */

/*
 * Usage example:
 * 

Ext.create('Ext.ux.GTFilterWindow', {
    store: 'storeId', 				// or Ext.data.Store object
    fields: [{
        name: 'modelField', 		// (required) same name as the Model property of the store
        label: 'displayValue',		// (required) this is the label shown on the combobox "Field"
        handler: {					// (required)
            type: 'interval',		// can be 'text', 'opentext', 'numeric', 'interval' or 'date'
            minValue: 0,			// default: 0.0
            maxValue: 100,			// default: 100.0
            increment: 1,			// default: 0.1
            decimalPrecision: 0		// default: 1
       }
    },{
        name: 'modelField',
        label: 'displayValue',
        handler: {
            type: 'text',				
            values: ['asd', 'qwe']			// checkbox display value == input value
       }
    },{
        name: 'modelField',
        label: 'displayValue',
        handler: {
            type: 'text',
            values: ['Yes', 'No', {	
            	label: 'N/A',				// checkbox display value != input value
            	value: null
            }]
       }
    },{
        name: 'modelField',
        label: 'displayValue',
        handler: {
            type: 'text'					// textfield display
       }
    }]
});


 */

Ext.define('Ext.ux.GTFilterWindow', {
    extend: 'Ext.window.Window',
    alias: ['widget.gtfilterwindow'],
    
    layout: 'fit',
    
    title: 'Aplicar Filtros',
    
    modal: true,
    closable: true,
    width: 450,
    height: 400,
    
    filterString: 'Filtro',
    addFilterString: 'Adicionar Filtro',
    fieldString: 'Campo',
    noneFieldString: 'Nenhum',
    
    okString: 'Filtrar',
    cancelString: 'Cancelar',
    //applyString: 'Aplicar',
    
    // Filters Specific Default Configuration
    textFilterEmptyString: 'Não informado',
    
    maxIntervals: 4,
    
    intervalFilterMinValue: 0.0,
    intervalFilterMaxValue: 100.0,
    intervalFilterIncrement: 0.1,
    intervalFilterPrecision: 1.0,
    
    numericFilterPrecision: 1.0,
    
    dateFilterFormat: 'd/m/Y',
    
    createTabDelay: 300,
    creatingTab: false,
    
    stackFilters: false,
    
    defaultFilterTab: {
    	layout: 'anchor',
    	closable: true,
    	bodyPadding: 15,
    	items: [{
    		xtype: 'form',
    		layout: 'fit',
    		border: false,
    		margin: '15px 0 0 0',
    		width: 400,
    		height: 250,
    		itemId: 'filterForm',
    		fieldId: null,
    		getFilterObject: function () {
        		return null;
        	}
    	}],
    	listeners: {
    		beforeclose: function (tab) {
    			var tabpanel = tab.ownerCt;
    			if (tabpanel.activeTab === tab)
    				tabpanel.setActiveTab(tab.previousSibling());
    		}
    	}
    },
    
    filtersPanel: {
    	'text': function (field, filterForm) {
    		var items = [];
        	
        	if (!field.handler.values) {
        		console.log('Error: Ext.ux.GTFilterWindow expects a text filter handler with values array containing {label: "", value: ""} objects.');
        	}
        	else if (field.handler.values instanceof Array) {
        		// create checkboxes according to values config
        		
        		for (var i = 0; i < field.handler.values.length; i++) {
        			var v = field.handler.values[i];
        			var label, value;
        			if (typeof(v) == "string") {
        				// checkbox with display value == input value
        				label = v;
        				value = v;
        			}
        			else if (typeof(v) == "object" && v.label !== null && v.value !== null) {
        				// checkbox with display value != input value
        				label = v.label;
        				value = v.value;
        			}
        			else {
        				console.log('Error: Ext.ux.GTFilterWindow expects a text filter handler with values array containing {label: "", value: ""} objects.');
        				label = null;
        				value = null;
        			}
        				
        			items.push({
        				boxLabel: label,
        				name: field.name,
        				inputValue: value
        			});
        		}
        	}
        	else {
        		console.log('Error: Ext.ux.GTFilterWindow expects a text filter handler with attribute "values" of type Array');
        	}
        		
    		filterForm.removeAll();
    		filterForm.add({
    			xtype: 'gtcheckboxgroup',
    			checkboxGroupConfig: {
    				columns: 2,
    				vertical: true,
    				items: items
    			}
    		});
    		
    		filterForm.getFilterObject = function () {
    			var me = this;
    			
    			var checkboxgroup = filterForm.items.getAt(0);
    			var values = checkboxgroup.getValue();
    			
    			var queryValues = [];
    			var field = me.fieldId;
    			
    			var arrValues = values[field];
    			if (arrValues instanceof Array) {
    				for (var i = 0; i<arrValues.length; i++) {
    					queryValues.push(arrValues[i]);
    				}
    			}
    			else {
    				queryValues.push(arrValues);
    			}
    			
    			return {
    				property: field + "-options",
    				value: queryValues.join(";")
    			};
    		};
    	},
    	
    	'opentext': function (field, filterForm) {
    		var me = this;
        	var items = new Array;
        	var maxIntervals = me.maxIntervals;
        	
        	for (var i=0; i < maxIntervals; i++) {
        		// checkbox
        		items.push({
    				xtype: 'checkbox',
    				itemId: 'checkbox'+(i+1),
    				margin: (i==0 ? '30px 15px 0 0' : '15px 15px 0 0'),
    				checked: i==0,
    				columnWidth: 0.2,
    				listeners: {
    					change: function(checkbox, newValue) {
    						checkbox.nextNode().setDisabled(!newValue);
    					}
    				}
    			});
        		
        		// textfield
        		items.push({
    				xtype: 'textfield',
    				itemId: 'opentext'+(i+1),
    				disabled: i!=0,
    				fieldLabel: (i==0 ? 'Valor' : ''),
    				columnWidth: 0.8
    			});
        	}
    		
    		filterForm.removeAll();
    		filterForm.add({
    			xtype: 'form',
    			border: false,
    			layout: 'column',
    			itemId: 'form',
    			defaults: {
    				labelAlign: 'top',
    				margin: '15px 15px 0 0'
    			},
    			items: items
    		});
    		
    		filterForm.getFilterObject = function () {
    			var me = this;
    			var form = me.getComponent('form');
    			
    			var values = [];
    			
    			for (var i=0; i < maxIntervals; i++) {
    				var index = i+1;
    				var checkbox = form.getComponent('checkbox'+index);
    				if (checkbox.getValue() == true) {
    					var value = form.getComponent('opentext'+index).getValue();
    					
    					values.push(value);
    				}
    			}
    			
    			var field = me.fieldId;

    			return {
    				property: field + "-text",
    				value: values.join(";")
    			};
    		};
        },
        
        'numeric': function (field, filterForm) {
        	
        	var me = this;
        	var maxIntervals = me.maxIntervals;
        	var minValue = field.handler.minValue;
        	var maxValue = field.handler.maxValue;
        	var decimalPrecision = (field.handler.decimalPrecision ? field.handler.decimalPrecision : me.numericFilterPrecision);
        	
        	if (field.handler.forceValues) {
        		maxValue = null;
        		minValue = null;
        		me.store.each(function (item) {
        			var v = item.get(field.name);
        			if (maxValue === null || maxValue < v)
        				maxValue = v;
        			
        			if (minValue === null || minValue > v)
        				minValue = v;
        		});
        	}
        	
        	var items = [];
        	
        	for (var i=0; i < maxIntervals; i++) {
        		// checkbox
        		items.push({
    				xtype: 'checkbox',
    				itemId: 'checkbox'+(i+1),
    				margin: (i==0 ? '30px 15px 0 0' : '15px 15px 0 0'),
    				checked: i==0,
    				columnWidth: 0.2,
    				listeners: {
    					change: function(checkbox, newValue) {
    						checkbox.nextNode().setDisabled(!newValue).nextNode().setDisabled(!newValue);
    					}
    				}
    			});
        		
        		// minText
        		items.push({
    				xtype: 'numberfield',
    				itemId: 'min'+(i+1),
    				disabled: i!=0,
    				allowDecimals: decimalPrecision > 0,
    				decimalPrecision: decimalPrecision,
    				fieldLabel: (i==0 ? 'Min' : ''),
    				minValue: minValue,
    				value: minValue,
    				hideTrigger: true,
    		        keyNavEnabled: false,
    		        mouseWheelEnabled: false,
    				columnWidth: 0.4,
    				listeners: {
    					blur: function(field) {
    						var newValue = field.getValue();
    						var maxValue = field.nextNode().getValue();
    						
    						if (newValue !== null && maxValue !== null) {
    							if (newValue > maxValue) {
    								newValue = maxValue;
    								field.setValue(newValue);
    							}
    							else if (newValue < field.minValue) {
    								newValue = field.minValue;
    								field.setValue(newValue);
    							}
    						}
    					}
    				}
    			});
        		
        		// maxText
        		items.push({
    				xtype: 'numberfield',
    				itemId: 'max'+(i+1),
    				disabled: i!=0,
    				allowDecimals: decimalPrecision > 0,
    				decimalPrecision: decimalPrecision,
    				fieldLabel: (i==0 ? 'Max' : ''),
    				maxValue: maxValue,
    				value: maxValue,
    				hideTrigger: true,
    		        keyNavEnabled: false,
    		        mouseWheelEnabled: false,
    				columnWidth: 0.4,
    				margin: '15px 0 0 0',
    				listeners: {
    					blur: function(field) {
    						var newValue = field.getValue();
    						var minValue = field.previousSibling().getValue();
    						
    						if (newValue !== null && minValue !== null) {
    							if (newValue < minValue) {
    								newValue = minValue;
    								field.setValue(newValue);
    							}
    							else if (newValue > field.maxValue) {
    								newValue = field.maxValue;
    								field.setValue(newValue);
    							}
    						}
    					}
    				}
    			});
        	}
    		
    		filterForm.removeAll();
    		filterForm.add({
    			xtype: 'form',
    			border: false,
    			layout: 'column',
    			itemId: 'form',
    			defaults: {
    				labelAlign: 'top',
    				margin: '15px 15px 0 0'
    			},
    			items: items
    		});
    		
    		filterForm.getFilterObject = function () {
    			var me = this;
    			var form = me.getComponent('form');
    			
    			var intervals = [];
    			
    			for (var i=0; i < maxIntervals; i++) {
    				var index = i+1;
    				var checkbox = form.getComponent('checkbox'+index);
    				if (checkbox.getValue() == true) {
    					var minValue = form.getComponent('min'+index).getValue();
    					var maxValue = form.getComponent('max'+index).getValue();
    					
    					intervals.push(minValue, maxValue);
    				}
    			}
    			
    			var field = me.fieldId;

    			return {
    				property: field + '-interval',
    				value: intervals.join(";")
    			};
    		};
        },
        
        'interval': function (field, filterForm) {
        	var me = this;
        	var maxIntervals = me.maxIntervals;
        	var minValue = (field.handler.minValue ? field.handler.minValue : me.intervalFilterMinValue);
        	var maxValue = (field.handler.maxValue ? field.handler.maxValue : me.intervalFilterMaxValue);
        	var increment = (field.handler.increment ? field.handler.increment : me.intervalFilterIncrement);
        	var decimalPrecision = (field.handler.decimalPrecision ? field.handler.decimalPrecision : me.intervalFilterPrecision);
        	
        	if (field.handler.forceValues) {
        		maxValue = null;
        		minValue = null;
        		me.store.each(function (item) {
        			var v = item.get(field.name);
        			if (maxValue === null || maxValue < v)
        				maxValue = v;
        			
        			if (minValue === null || minValue > v)
        				minValue = v;
        		});
        		
        		increment = (maxValue - minValue) / 100;
        	}
        	
        	var items = [];
        	
        	for (var i=0; i < maxIntervals; i++) {
        		// checkbox
        		items.push({
    				xtype: 'checkbox',
    				itemId: 'checkbox'+(i+1),
    				margin: (i==0 ? '30px 15px 0 0' : '15px 15px 0 0'),
    				checked: i==0,
    				columnWidth: 0.1,
    				listeners: {
    					change: function(checkbox, newValue) {
    						checkbox.nextNode().setDisabled(!newValue).nextNode().setDisabled(!newValue).nextNode().setDisabled(!newValue);
    					}
    				}
    			});
        		
        		// slider
        		items.push({
    				xtype: 'slider',
    				itemId: 'slider'+(i+1),
    				disabled: i!=0,
    				fieldLabel: (i==0 ? 'Intervalo' : ''),
    				decimalPrecision: decimalPrecision,
    				minValue: minValue,
    				maxValue: maxValue,
    				increment: increment,
    				values: [minValue, maxValue],
    				columnWidth: 0.5,
    				tipText: function (thumb) {
    					var newValue = thumb.value;
    					var slider = thumb.slider;
    					var values = slider.getValues();
    					
    					if (thumb.index == 0 && newValue > values[1]) {
    						newValue = values[1];
    					}
    					else if (thumb.index == 1 && newValue < values[0]) {
    						newValue = values[0];
    					}
    					else if (newValue < slider.minValue) {
    						newValue = slider.minValue;
    					}
    					else if (newValue > slider.maxValue) {
    						newValue = slider.maxValue;
    					}
    					
    					
    					
    					return newValue.toFixed(slider.decimalPrecision);
    				},
    				listeners: {
    					changecomplete: function(slider, newValue, thumb) {
    						var target = slider;
    						for (var i=0; i<=thumb.index; i++) {
    							target = target.nextNode();
    						}
    						
    						target.setValue(newValue);
    					}
    				}
    			});
        		
        		// minText
        		items.push({
    				xtype: 'numberfield',
    				itemId: 'min'+(i+1),
    				disabled: i!=0,
    				allowBlank: false,
    				allowDecimals: decimalPrecision > 0,
    				decimalPrecision: decimalPrecision,
    				fieldLabel: (i==0 ? 'Min' : ''),
    				minValue: minValue,
    				value: minValue,
    				hideTrigger: true,
    		        keyNavEnabled: false,
    		        mouseWheelEnabled: false,
    				columnWidth: 0.2,
    				listeners: {
    					blur: function(field) {
    						var newValue = field.getValue();
    						var maxValue = field.nextNode().getValue();
    						
    						if (newValue > maxValue) {
    							newValue = maxValue;
    							field.setValue(newValue);
    						}
    						else if (newValue < field.minValue) {
    							newValue = field.minValue;
    							field.setValue(newValue);
    						}
    						
    						var slider = field.previousSibling();
    						
    						slider.setValue(0, newValue);
    					}
    				}
    			});
        		
        		// maxText
        		items.push({
    				xtype: 'numberfield',
    				itemId: 'max'+(i+1),
    				disabled: i!=0,
    				allowDecimals: decimalPrecision > 0,
    				decimalPrecision: decimalPrecision,
    				allowBlank: false,
    				fieldLabel: (i==0 ? 'Max' : ''),
    				maxValue: maxValue,
    				value: maxValue,
    				hideTrigger: true,
    		        keyNavEnabled: false,
    		        mouseWheelEnabled: false,
    				columnWidth: 0.2,
    				margin: '15px 0 0 0',
    				listeners: {
    					blur: function(field) {
    						var newValue = field.getValue();
    						var minValue = field.previousSibling().getValue();
    						
    						if (newValue < minValue) {
    							newValue = minValue;
    							field.setValue(newValue);
    						}
    						else if (newValue > field.maxValue) {
    							newValue = field.maxValue;
    							field.setValue(newValue);
    						}
    						
    						var slider = field.previousSibling().previousSibling();
    						
    						slider.setValue(1, newValue);
    					}
    				}
    			});
        	}
    		
    		filterForm.removeAll();
    		filterForm.add({
    			xtype: 'form',
    			border: false,
    			layout: 'column',
    			itemId: 'form',
    			defaults: {
    				labelAlign: 'top',
    				margin: '15px 15px 0 0'
    			},
    			items: items
    		});
    		
    		filterForm.getFilterObject = function () {
    			var me = this;
    			var form = me.getComponent('form');
    			
    			var intervals = [];
    			
    			for (var i=0; i < maxIntervals; i++) {
    				var index = i+1;
    				var checkbox = form.getComponent('checkbox'+index);
    				if (checkbox.getValue() == true) {
    					var minValue = form.getComponent('min'+index).getValue();
    					var maxValue = form.getComponent('max'+index).getValue();
    					
    					intervals.push(minValue, maxValue);
    				}
    			}
    			
    			var field = me.fieldId;

    			return {
    				property: field + '-interval',
    				value: intervals.join(";")
    			};
    		};
        },
        
        'date': function (field, filterForm) {
        	var me = this;
        	var maxIntervals = me.maxIntervals;
        	var minValue = field.handler.minValue;
        	var maxValue = field.handler.maxValue;
        	var dateFormat = (field.handler.dateFormat ? field.handler.dateFormat : me.dateFilterFormat);
        	
        	if (field.handler.forceValues) {
        		maxValue = null;
        		minValue = null;
        		me.store.each(function (item) {
        			var v = item.get(field.name);
        			if (maxValue === null || maxValue < v)
        				maxValue = v;
        			
        			if (minValue === null || minValue > v)
        				minValue = v;
        		});
        	}
        	
        	var items = [];
        	
        	for (var i=0; i < maxIntervals; i++) {
        		// checkbox
        		items.push({
    				xtype: 'checkbox',
    				itemId: 'checkbox'+(i+1),
    				margin: (i==0 ? '30px 15px 0 0' : '15px 15px 0 0'),
    				checked: i==0,
    				columnWidth: 0.2,
    				listeners: {
    					change: function(checkbox, newValue) {
    						checkbox.nextNode().setDisabled(!newValue).nextNode().setDisabled(!newValue);
    					}
    				}
    			});
        		
        		// minText
        		items.push({
    				xtype: 'datefield',
    				itemId: 'min'+(i+1),
    				disabled: i!=0,
    				fieldLabel: (i==0 ? 'Min' : ''),
    				minValue: minValue,
    				maxValue: maxValue,
    				value: minValue,
    				format: dateFormat,
    				columnWidth: 0.4,
    				listeners: {
    					blur: function(field) {
    						var newValue = field.getValue();
    						var maxValue = field.nextNode().getValue();
    						
    						if (newValue !== null && maxValue !== null) {
    							if (newValue > maxValue) {
    								newValue = maxValue;
    								field.setValue(newValue);
    							}
    							else if (newValue < field.minValue) {
    								newValue = field.minValue;
    								field.setValue(newValue);
    							}
    						}
    					}
    				}
    			});
        		
        		// maxText
        		items.push({
    				xtype: 'datefield',
    				itemId: 'max'+(i+1),
    				disabled: i!=0,
    				fieldLabel: (i==0 ? 'Max' : ''),
    				minValue: minValue,
    				maxValue: maxValue,
    				value: maxValue,
    				format: dateFormat,
    				columnWidth: 0.4,
    				margin: '15px 0 0 0',
    				listeners: {
    					blur: function(field) {
    						var newValue = field.getValue();
    						var minValue = field.previousSibling().getValue();
    						
    						if (newValue !== null && minValue !== null) {
    							if (newValue < minValue) {
    								newValue = minValue;
    								field.setValue(newValue);
    							}
    							else if (newValue > field.maxValue) {
    								newValue = field.maxValue;
    								field.setValue(newValue);
    							}
    						}
    					}
    				}
    			});
        	}
    		
    		filterForm.removeAll();
    		filterForm.add({
    			xtype: 'form',
    			border: false,
    			layout: 'column',
    			itemId: 'form',
    			defaults: {
    				labelAlign: 'top',
    				margin: '15px 15px 0 0'
    			},
    			items: items
    		});
    		
    		filterForm.getFilterObject = function () {
    			var me = this;
    			var form = me.getComponent('form');
    			
    			var intervals = [];
    			
    			for (var i=0; i < maxIntervals; i++) {
    				var index = i+1;
    				var checkbox = form.getComponent('checkbox'+index);
    				if (checkbox.getValue() == true) {
    					var minValue = form.getComponent('min'+index).getValue();
    					var maxValue = form.getComponent('max'+index).getValue();
    					
    					intervals.push(GeoTech.utils.formatDate('dd/mm/yyyy', minValue), GeoTech.utils.formatDate('dd/mm/yyyy', maxValue));
    				}
    			}
    			
    			var field = me.fieldId;

    			return {
    				property: field + '-dateinterval',
    				value: intervals.join(";")
    			};
    		};
        }
    },
    
    applyFilters: function () {
    	var me = this;
    	var tabpanel = me.getComponent('tabpanel');
		var tabs = tabpanel.items;
		var l = tabs.getCount();
		
		var filters = [];
		for (var i = 0; i<l; i++) {
			var tab = tabs.getAt(i);
			if (tab.tabId == 'newFilter')
				break;
			
			var filter = tab.getComponent('filterForm').getFilterObject();
			if (filter != null) {
				filters.push(filter);
			}
		}
		
		if (!me.stackFilters)
		 	me.store.clearFilter();
		
		me.store.filter(filters);
    },
    
    getFilterForm: function () {
    	var me = this;
    	
    	return me.getComponent('tabpanel').getActiveTab().getComponent('filterForm');
    },
 
    initComponent: function() {
    	var me = this;
    	
    	// store attribute (required)
    	if (!me.store) {
    		console.log('Error: Ext.ux.GTFilterWindow expects a "store" config parameter.');
    		return null;
    	}
    	else {
    		if (typeof(me.store) == "string")
    			me.store = Ext.data.StoreManager.lookup(me.store);
    	}
    	
    	// fields filters
    	var combo, comboStore;
    	
    	if (!me.fields || !me.fields instanceof Array) {
    		console.log('Error: Ext.ux.GTFilterWindow expects a "fields" config parameter as an Array.');
    		return null;
    	}
    	else {
    		// assigning form creation functions to each record
    		var allowedTypes = new Array;
    		for (var i in me.filtersPanel) {
    			allowedTypes.push(i);
    		}
    		
    		for (var i = 0; i < me.fields.length; i++) {
    			var record = me.fields[i];
    			if (record && record.handler) {
    				var fn = me.filtersPanel[record.handler.type];
    				if (typeof(fn) == "function") {
    					me.fields[i].filterFormFn = fn;
    				}	
    				else {
    					console.log('Error: Ext.ux.GTFilterWindow expects "handler type" config parameter with the following values ' + allowedTypes.join(',') + '.');
    				}
	    		}
	    		else {
	    			console.log('Error: Ext.ux.GTFilterWindow expects "fields" config parameter with a "handler" attribute.');
	    		}
    		}
    		
    		me.fields.splice(0,0,{
    			name: me.noneFieldString,
    			label: me.noneFieldString,
    			fieldId: null,
    			filterFormFn: function (field, filterForm) {
	    			filterForm.fieldId = null;
	    			filterForm.removeAll();
	    			filterForm.getFilterObject = function () { return null; };
	    			return;
	    		}
    		});
    		
    		comboStore = Ext.create('Ext.data.Store', {
    		    fields: ['name', 'label', 'handler'],
    		    data : me.fields,
    		    autoLoad: true
    		});
    		
    		combo = Ext.create('Ext.form.ComboBox', {
    			fieldLabel: me.fieldString,
    			store: comboStore,
    			queryMode: 'local',
    		    displayField: 'label',
    		    valueField: 'name',
    		    value: me.noneFieldString,
    		    listeners: {
    		    	select: function(combo, records) {
    		    		var filterForm = combo.ownerCt.getComponent('filterForm');

    		    		try {
    		    			var record = records[0].raw;
    		    			filterForm.fieldId = record.name;
    		    			record.filterFormFn.call(me, record, filterForm);
    		    		}
    		    		catch (ex) {
    		    			console.log('Ext.ux.GTFilterWindow: could not load filter form for option "'+ combo.getValue() +'".');
    		    		}
    		    	}
    		    }
    		});
    	}
    	
    	var firstTab = Ext.create('Ext.panel.Panel', Ext.apply(me.defaultFilterTab, {
    		closable: false,
    		title: 'Filtro 1'
    	}));
    	firstTab.insert(0, combo);
    	
    	me.items = [{
    		xtype: 'tabpanel',
    		itemId: 'tabpanel',
    		filterCounter: 1,
    		items: [firstTab,{
    			title: me.addFilterString,
    			tabId: 'newFilter'
    		}],
    		listeners: {
    			beforetabchange: function (tabPanel, newCard, oldCard) {
    				if (newCard.tabId == 'newFilter') {
    					if (me.creatingTab)
    						return false;
    					else
    						me.creatingTab = true;
    					
    					var position = tabPanel.items.getCount() - 1;
    					tabPanel.filterCounter += 1;
    					
    					var tab = Ext.create('Ext.panel.Panel', Ext.apply(me.defaultFilterTab, {
    			    		title: me.filterString + ' ' + tabPanel.filterCounter,
    			    		closable: true
    			    	}));
    			    	tab.insert(0, combo.cloneConfig());
    					
    					tabPanel.insert(position, tab);
    					tabPanel.setActiveTab(tabPanel.filterCounter - 1);
    					
    					setTimeout(function () {
    						me.creatingTab = false;
    					}, me.createTabDelay);
    					
    					return false;
    				}
    			}
    		}
    	}];
    	
    	me.buttons = [{
    		text: me.okString,
    		handler: function (btn) {
    			var win = btn.up('window'); // window
    			
    			win.applyFilters();
    			
    			if (win.closeAction == 'hide') {
    				win.hide();
    			}
    			else {
    				win.close();
    			}
    		}
    	},{
    		text: me.cancelString,
    		handler: function (btn) {
    			var win = btn.up('window'); // window
    			if (win.closeAction == 'hide') {
    				win.hide();
    			}
    			else {
    				win.close();
    			}
    		}
    	}];

    	me.callParent(arguments);
    }
});
