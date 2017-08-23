/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.tools.VerifyDataPanel', {
	extend: 'Ext.panel.Panel',

	title: 'Consolidação dos dados',
	
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
    		    '3 - Defina quais tabelas devem ser consolidadas.'
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
    		width: 350,
    		title: 'Tabelas que serão consolidadas',
    		layout: 'fit',
    		items: [{
    			xtype: 'checkboxgroup',
    			margin: 10,
    			columns: 2,
    			defaults: {
    				checked: true
    			},
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
    	            name: 'activities'
				},{
					boxLabel: 'Conflitos',
					name: 'conflicts'
				}]
    		}]
    	},{
    		xtype: 'button',
    		text: 'Consolidar',
    		formBind: true,
    		handler: function (btn) {
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
						text: 'Consolidando dados...'
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
    							lbl.update('Consolidando dados... ' + Math.round(Ext.Date.getElapsed(start) / 1000) + "s");
    						}
    					}
					}]
				});
				
				waitWin.show();
				
				
				
				form.submit({
	                url: 'actions/verifyData.jsp',
					success: function (form, action) {
						waitWin.hide();
						
						Ext.create('Ext.window.Window', {
							modal: true,
							closable: true,
							
							title: 'Resultado da consolidação',
							
							layout: 'fit',
							
							width: 820,
							height: 400,
							
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
                			GTPlanner.showErrorMessage('Consolidação de dados de dados');
	                	}
	                }
	            
				});
			}
    	}]
	}]

});