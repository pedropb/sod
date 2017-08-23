/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.definitions.ImportDataPanel', {
	extend: 'Ext.panel.Panel',

	title: 'Importar definições',
	
	layout: 'fit',
	
	items: [{
		xtype: 'form',
		layout: 'vbox',
		bodyPadding: 10,
		defaults: {
			margin: 10
		},
		items: [{
    		xtype: 'gtinstructions',
    		instructions: [
    		    '1 - Faça o download do modelo de importação dos dados: <a href="sod_data_input.xls" target="_blank">XLS</a> ou <a href="sod_data_input.xlsx" target="_blank">XLSX</a>',
    		    '2 - Preencha o modelo conforme as instruções que estão escritas na primeira planilha.',
    		    '3 - Defina quais os dados devem ser apagados antes da importação.',
    		    '4 - <b>Atenção! Apagar os dados antes da importação é uma operação definitiva, impossível de ser desfeita. Por isso, faça um backup antes.</b>'
    		]
    	},{
    		xtype: 'filefield',
    		labelWidth: 220,
    		width: 540,
    		fieldLabel: 'Arquivo de importação (.xls ou .xlsx)',
    		buttonText: 'Procurar...',
    		emptyText: 'Excel 97-2003 (.xls) ou 2007-2010 (.xlsx)',
    		name: 'import_file',
    		allowBlank: false,
    		regex: /\.xlsx?$/,
    		regexText: 'O arquivo deve ter a extensão xls ou xlsx'
    	},{
    		xtype: 'fieldset',
    		checkboxToggle: true,
    		checkboxName: 'clean_db',
    		width: 350,
    		title: 'Apagar dados antes da importação',
    		layout: 'fit',
    		collapsed: true,
    		items: [{
    			xtype: 'checkboxgroup',
    			margin: 10,
    			columns: 2,
    			items: [{
    				boxLabel: 'Usuários',
    				name: 'users'
				},{
					boxLabel: 'Grupos',
					name: 'groups'
				},{
					boxLabel: 'Módulos',
					name: 'modules'
				},{
					boxLabel: 'Transações',
					name: 'transactions'
				},{
					boxLabel: 'Atividades',
    	            name: 'activities',
    	            listeners: {
    	            	change: function (comp, newValue) {
    	            		if (newValue) {
    	            			comp.nextSibling().setValue(true);
    	            		}
    	            	}
    	            }
				},{
					boxLabel: 'Conflitos',
					name: 'conflicts',
    	            listeners: {
    	            	change: function (comp, newValue) {
    	            		if (comp.previousSibling().getValue()) {
    	            			comp.setValue(true);
    	            			return false;
    	            		}
    	            	}
    	            }
				},{
					boxLabel: 'Aceites de Usuários',
					name: 'users_solutions'
				},{
					boxLabel: 'Aceites de Grupos',
					name: 'groups_solutions'
				}]
    		}],
    		listeners: {
    			expand: function (fieldset) {
    				var chkboxgroup = fieldset.down('checkboxgroup');
    				var chkbox = chkboxgroup.down('checkbox');
    				while (chkbox) {
    					if (chkbox.boxLabel.indexOf("Aceites") !== 0) {
    						chkbox.setValue(true);
    					}
    					
    					chkbox = chkbox.next('checkbox');
    				}
    			}
    		}
    	},{
    		xtype: 'button',
    		text: 'Importar definições',
    		formBind: true,
    		handler: function (btn) {
    			var submitFn = function () {
    				var form = btn.up('form');
    				
    				var start = new Date();
    				var waitWin = Ext.create('Ext.window.Window', {
    					title: 'Aguarde',
    					modal: true,
    					closable: false,
    					
    					bodyStyle: {
    						background: 'none',
    						border: 'none'
    					},
    					
    					width: 250,
    					height: 110,
    					bodyPadding: 10,
    					
    					items: [{
    						xtype: 'label',
    						text: 'Importando dados...'
    					},{
    						xtype: 'progressbar',
    						width: 220,
    						margin: '10 0 0 0',
    						listeners: {
    							afterrender: function (bar) {
    								bar.wait({
    									interval: 1000,
    									increment: 15
    								});
    							},
        						update: function (bar) {
        							var win = bar.up('window');
        							var lbl = win.down('label');
        							lbl.update('Importando dados... ' + Math.round(Ext.Date.getElapsed(start) / 1000) + "s");
        						}
        					}
    					}]
    				});
    				
    				waitWin.show();
    				
    				form.submit({
		                url: 'actions/importData.jsp',
						success: function (form, action) {
							waitWin.hide();
							
							Ext.create('Ext.window.Window', {
								modal: true,
								closable: true,
								
								title: 'Resultado da importação',
								
								layout: 'fit',
								
								width: 400,
								height: 300,
								
								bodyPadding: 10,
								
								items: [{
									xtype: 'textarea',
									readOnly: true,
									value: action.result.output
								}]
							}).show();
		                },
		                failure: function(form, action) {
		                	waitWin.hide();
		                	
		                	if (action && action.result && typeof(action.result.message) == "string")
		                		Ext.Msg.alert('Atenção!', action.result.message);
		                	else {
	                			GTPlanner.showErrorMessage('Importação de dados');
		                	}
		                }
		            
					});
    			};
    			
    			var fs = btn.previousSibling();
    			if (!fs.collapsed) {
    				var willDelete = 0;
    				var chkgroup = fs.items.items[0];
    				for (var i = 0; i < chkgroup.items.items.length; i++) {
    					if (chkgroup.items.items[i].getValue()) {
    						willDelete++;
    					}
    				}
    				
    				if (willDelete > 0) {
    					Ext.Msg.confirm("Atenção!", "<b>" + willDelete + " tabelas de definições serão apagadas antes da importação.<br>Essa operação não pode ser desfeita.</b><br>Deseja continuar?", function (answer) {
							if (answer == "yes") {
								submitFn();
							}
						});
    				}
    				else {
    					submitFn();
    				}
    			}
		    	else {
		    		submitFn();
		    	}
    		}
    	}]
	}]

});