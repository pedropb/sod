/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.definitions.ExportDataPanel', {
	extend: 'Ext.panel.Panel',

	title: 'Exportar definições',
	
	layout: 'vbox',
	bodyPadding: 20,
	
	items: [{
		xtype: 'gtinstructions',
		instructions: 'Selecione o formato, clique no botão e aguarde o download.'
	},{
		xtype: 'radiogroup',
		fieldLabel: 'Formato',
		vertical: true,
		columns: 1,
		defaults: {
			name: 'format'
		},
		items: [{
			boxLabel: 'XLS (Excel 97-2003)',
			inputValue: 'XLS',
			id: 'xls-radiobtn'
		},{
			boxLabel: 'XLSX (Excel 2007-*)',
			inputValue: 'XLSX',
			checked: true
		}]
	},{
		xtype: 'button',
		text: 'Exportar definições',
		handler: function () {
			GeoTech.utils.formSubmit({
				url: 'actions/exportData.jsp',
				params: {
					format: Ext.getCmp('xls-radiobtn').getValue() ? 'XLS' : 'XLSX'
				}
			});
		}
	}]
});