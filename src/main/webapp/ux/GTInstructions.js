/*
 * ExtJS User Extension - GTInstructions
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 * 
 * A simple component to render instructions anywhere
 * Usage Example:
{
	xtype: 'gtinstructions',
	padding: 10,
	instructions: [
	    '- Instruction 1',
	    '- Instruction 2'
	],
}
 * 
 */

Ext.define('Ext.ux.GTInstructions', {
	extend: 'Ext.Component',
	alias: ['widget.gtinstructions'],
	
	minHeight: 100,
	headerTitle: 'Instruções',
	
	initComponent: function () {
		var me = this;
		
		me.callParent(arguments);
		
		if (typeof(me.instructions) == "string") {
			me.instructions = [me.instructions];
		}
		else if (!(me.instructions instanceof Array)) {
			console.log('GTInstructions: instructions config must be string or string[].');
			return;
		}
		
		var html = '<p style="font-size: 1.17em; font-weight: bold;">'+ me.headerTitle +':</p>' + me.instructions.join('<br>');
		
		me.update(html);
	}
	
});