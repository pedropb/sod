/*
 * ExtJS User Extension - CepField
 * Desenvolvido por Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('Ux.CepField', {
   extend: 'Ext.form.field.Text',
   alias: ['widget.cepfield'],

   autocomplete: "off",

   initComponent: function(){
      var me = this;

      Ext.apply(Ext.form.VTypes, {
         cep: function(b, a) {
             return me.verificaCep(b);
         },
         cepText: "Número de CEP inválido."
      });

      Ext.apply(me, { vtype: 'cep' });

      me.callParent();
   },
   initEvents: function() {
      var me = this;
      
      me.callParent();
   },
   maskRe: /[0-9]/,
   clearMask: function() {
	   this.inputEl.dom.value = this.inputEl.dom.value.replace(/[\s\-]/g, "");
   },
   initMask: function() {
	   var data = this.inputEl.dom.value;
	   
	   data = data.replace(/[\s\-]/g, "");
	   
	   if (data.length == 0)
		   return;
	   
	   // Filling in extra spaces until data has 8 "digits"
	   for (var i=data.length; i < 8; i++)
		   data += " ";
	   
	   // Formatting PHONE 00000-000
	   data = data.substr(0,5) + "-" + data.substr(5,3);
	   
	   this.inputEl.dom.value = data;
   },
   verificaCep: function(a) {
	   var b = a.replace(/[\s\-]/g, ""); 
      
      if (b.length != 8 && b.length != 0)
    	  return false;

      return true;
   }
});