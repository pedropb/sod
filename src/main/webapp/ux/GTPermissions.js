/*
 * ExtJS User Extension - GTPanel
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 * 
 * Usage Example:
 * {
    	xtype: 'gtpermissions',
		itemId: 'permissions',
		labelWidth: 220,
		userId: 5,
		groupId: 3,
		loadingMask: true, // default value: false
		targetContainer: window // optional
    }
 * 
 */
Ext.define('Ext.ux.GTPermissions', {

	extend: 'Ext.container.Container',
	alias: ['widget.gtpermissions'],
	
	layout: 'anchor',
	defaults: {
		anchor: '100%'
	},
	stateful: true,
	
	buildItems: function (labelWidth, groups) {
		var items = [];
		for (var i = 0; i < groups.length; i++){	
			var fs = new Ext.form.FieldSet({
	    		title: groups[i].group,
				collapsible: true,
				collapsed: true,
				stateful: true,
				stateId: escape(groups[i].group)
			});
			
			var perms = groups[i].permissions;
			for (var j = 0; j < perms.length; j++){
				if (typeof(perms[j].groupValue) == 'undefined') perms[j].groupValue = null;
				
				perms[j].value = perms[j].value > perms[j].groupValue ? perms[j].value : perms[j].groupValue;
				
				if (perms[j].readWrite)
				{
					fs.add({
						xtype: 'checkboxgroup',
			            fieldLabel: perms[j].permission,
			            labelWidth: labelWidth,
			    		items: [{
			            	boxLabel: 'Leitura',
			            	name: 'permission@*@' + perms[j].id + '@*@read',
			            	disabled: perms[j].groupValue > 0 ? true : false,
			            	checked: perms[j].value > 0,
			            	listeners: {
	                            change: function (field, checked) {
	                                if (!checked){
	                                	field.ownerCt.items.items[1].setValue(false);
	                                }
	                            }
	                        }
			            },{
			            	boxLabel: 'Escrita',
			            	name: 'permission@*@' + perms[j].id + '@*@write',
			            	disabled: perms[j].groupValue == 2 ? true : false,
			            	checked: perms[j].value == 2,
			            	listeners: {
	                            change: function (field, checked) {	                            	
	                                if (checked) {
	                                	field.ownerCt.items.items[0].setValue(true);
	                                }
	                            }
	                        }
			            }]
					});
				}
				else
				{
					fs.add({
						xtype: 'checkboxgroup',
			            fieldLabel: perms[j].permission,
			            labelWidth: labelWidth,
			    		items: [{
			            	boxLabel: 'Habilitado',
			            	name: 'permission@*@' + perms[j].id + '@*@enabled',
			            	disabled: perms[j].groupValue == 2 ? true : false,
			            	checked: perms[j].value == 2
			            }]
					});
				}
			}
			
			items.push(fs);
		};
		
		return items;
	},
	
	afterRender: function () {
		var me = this;

		me.loadPermissions(me.userId, me.groupId);
		
		me.callParent(arguments);
	},
	
	loadPermissions: function (userId, groupId) {
		var me = this;
		
		me.userId = userId;
		me.groupId = groupId;

		if (me.loadingMask) {
			if (me.targetContainer)
				me.targetContainer.setLoading(true);
			else
				Ext.getBody().mask('Carregando...');
		}
		
		Ext.Ajax.request({
			url: 'stores/commons/gtpermissions.jsp',
			params: {
				userId: me.userId,
				groupId: me.groupId
			},
			success: function (response) {
				var permissions;
				try {
					permissions = Ext.decode(response.responseText);
					me.setPermissions(permissions);
				}
				catch (ex) {
					console.log('GTPermissions: error while decoding permissions');
					console.dir(response.responseText);
				}
				
				if (me.loadingMask) {
					if (me.targetContainer)
						me.targetContainer.setLoading(false);
					else
						Ext.getBody().unmask();
				}
				
				me.fireEvent('loaded', me);
			},
			failure:  function (response) {
				if (me.targetContainer)
					me.targetContainer.setLoading(false);
				
				console.log('GTPermissions: error while retrieving permissions');
				console.dir(response);
			}
		});
	},

	setPermissions: function (permissions) {
		var me = this;
		
		me.removeAll();
		me.add(me.buildItems(me.labelWidth, permissions));
		
		return me;
	}
});