/*
 * ExtJS User Extension - GTWizard
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 * 
 * Example:
 * 
	multiSelection: true,
	tree: {
		label: 'Selecione a origem dos dados',
		nodes: [{
			text: 'Questionário',
			label: 'Selecione o tópico do questionário',
			action: function (node) {
				alert('Questão: ' + node.text);
			},
			nodes: [{
    			text: 'Resíduos',
    			label: 'Selecione as Questões',
    			nodes: [{
    				text: 'Resíduos Gerados'
    			},{
    				text: 'Quantidade de papel',
    				action: function () {
    					alert('Quantidade de papel');
    				}
    			}]
			}]
		}, {
			text: 'Sistema de Acompanhamento',
			label: 'Selecione o módulo do sistema',
			action: function (node) {
				alert('Acompanhamento: ' + node.text);
			},
			nodes: [{
				text: 'Capacitações',
				label: 'Selecione os campos desejados',
				nodes: [{
					text: 'Capacitação A'
				}]
			}, {
				text: 'Licenciamento',
				label: 'Selecione os campos desejados',
				nodes: [{
					text: 'FCE',
					action: function () {
						alert('fce');
					}
				}, {
					text: 'FOB'
				}]
			}]
		}]
	}; 
 * 
 */

Ext.define('Ext.ux.GTWizard', {
	extend: 'Ext.window.Window',
	alias: ['widget.gtwizard'],
	
	closable: true,
	modal: true,
	
	width: 600,
	height: 500,

	layout: 'anchor',
	autoScroll: true,
	
	constructor: function(config) {
		var me = this;
		
    	config.title = (config.title ? config.title : 'Wizard');
    	
    	me.tree = config.tree;
    	delete config.tree;
    	    	
    	if (me.tree.nodes == null)
    		me.tree.nodes = [];
    	
    	me.prepare(me.tree);    	
    	
		config.items = Ext.create('Ext.form.Panel', {
			frame: true,
			padding: 18
		});
    	
		config.buttons = [{
			text: 'Voltar',
			itemId: 'btn-voltar',
			handler: function (btn) {
    			var form = me.items.items[0];
    			
    			if (form.items.length > 1 && form.items.items[1].items.length > 0) {
    				var firstNode = form.items.items[1].items.items[0].node;
    				me.loadNodes(firstNode.parent.parent);
    			}
			}
		}, {
			text: 'Cancelar',
			itemId: 'btn-cancelar',
			hidden: true,
			handler: function (btn) {
				me.close();
			}
		}, {
			text: 'Finalizar',
			hidden: true,
			itemId: 'btn-finalizar',
			handler: function (btn) {
				for (var i = 0; i < me.selectedNodes.length; i++) {
					var node = me.selectedNodes[i];
					var action = node.action;
					
					var parent = node.parent;
					while (action == null && parent != null) {
						action = parent.action;
						parent = parent.parent;
					}
					
					if (action != null)
						action(node);
				}
				
				me.close();
			}
		}];
		
		delete config.layout;
		
		me.callParent(arguments);
		me.initConfig(config);
	},
	
	afterRender: function () {
		var me = this;
		
		var currentNode = me.tree;
		me.loadNodes(currentNode);
		
		me.callParent(arguments);
	},
	
	prepare: function (currentNode, parentNode) {
		var me = this;
					
		currentNode.parent = parentNode;
		
		if (currentNode.nodes == null)
			return;
			
		for (var i = 0; i < currentNode.nodes.length; i++) {
			me.prepare(currentNode.nodes[i], currentNode);
    	}
	},
	
	loadNodes: function (currentNode) {
		var me = this;
		
    	var bbar = me.getDockedItems('toolbar[dock="bottom"]')[0]; 
		
    	if (currentNode != null && currentNode.nodes.length > 0) {
    		var leaf = false;
    		if (me.multiSelection === true) {
    			for (var i = 0; i < currentNode.nodes.length; i++) {
    				if (currentNode.nodes[i].nodes == null || currentNode.nodes[i].nodes.length == 0) {
    					leaf = true;
    					break;
    				}
    			}
    		}
    		
    		var form = me.items.items[0];
    		form.removeAll();
    		
    		var items = [];
    		
    		for (var i = 0; i < currentNode.nodes.length; i++) {
    			items.push({
    				boxLabel: currentNode.nodes[i].text,
    				node: currentNode.nodes[i],
		        	name: 'wizard-nodes',
    				listeners: {
    					change: function (field, newValue, oldValue) {
    						if (newValue == false) {
    							for (var i = 0; i < me.selectedNodes.length; i++) {
    								if (me.selectedNodes[i] === field.node) {
										me.selectedNodes.splice(i, 1);
										return;
    								}    									
    							}
    						}
    						
    						me.selectedNodes.push(field.node);
    						
    						if (leaf)
    							return;
    						
    						if (field.node.nodes != null && field.node.nodes.length > 0) {
    							me.loadNodes(field.node);
    						}
    						else {
    							bbar.getComponent('btn-cancelar').setVisible(false);
    							bbar.getComponent('btn-finalizar').setVisible(true);    							
    						}
    					}
    				}
    			});
    		}
    		
    		form.add([{
		        xtype: 'label',
		        text: currentNode.label + ':',
		        style: 'font-weight: bold;'
		    },{
    			xtype: me.multiSelection && leaf ? 'checkboxgroup' : 'radiogroup',
        		hideLabel: true,
    			items: items,
    			vertical: true,
    			columns: 1,
    			width: '100%',
    			margin: '15 0 0 5'
    		}]);
    		
    		bbar.getComponent('btn-voltar').setVisible(currentNode.parent != null);
    		bbar.getComponent('btn-cancelar').setVisible(!(me.multiSelection && leaf));
    		bbar.getComponent('btn-finalizar').setVisible(me.multiSelection && leaf);
    		
    		me.selectedNodes = [];
    	}		
	}
});