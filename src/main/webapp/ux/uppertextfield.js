/*
 * ExtJS User Extension - UpperTextField
 * Desenvolvido por Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('Ext.ux.UpperTextField', {
   extend: 'Ext.form.field.Text',
   alias: ['widget.uppertextfield'],
   
   initComponent: function(){
      var me = this;
      
      me.on('change', function () {
    	  var v = me.getValue();
    	  if (typeof(v) == "string") {
    		  me.setValue(v.toUpperCase());
    	  }
      });

      me.callParent();
   }
});