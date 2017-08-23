/*
 * ExtJS User Extension - PhoneField
 * Desenvolvido por Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('Ux.PhoneField', {
   extend: 'Ext.form.field.Text',
   alias: ['widget.phonefield'],

   autocomplete: "off",

   initComponent: function(){
      var me = this;

      Ext.apply(Ext.form.VTypes, {
         phone: function(b, a) {
             return me.verificaPhone(b);
         },
         phoneText: "Número de telefone inválido.<br>Formato esperado: (xx) xxxx-xxxx"
      });

      Ext.apply(me, { vtype: 'phone' });

      me.callParent();
   },
   initEvents: function() {
      var me = this;
      
      me.on('focus', me.clearMask);
      me.on('blur', me.initMask);

      me.callParent(arguments);
   },
   maskRe: /[0-9]/,
   clearMask: function() {
	   this.inputEl.dom.value = this.inputEl.dom.value.replace(/[\s\(\)\-]/g, "");
   },
   initMask: function() {
	   var data = this.inputEl.dom.value;
	   
	   data = data.replace(/[\s\(\)\-]/g, "");
	   
	   if (data.length == 0)
		   return;
	   
	   // Filling in extra spaces until data has 10 "digits"
	   for (var i=data.length; i < 10; i++)
		   data += " ";
	   
	   // Formatting PHONE (00)0000-0000
	   data = "(" + data.substr(0,2) + ") " + data.substr(2,4) + "-" + data.substr(6,4);
	   
	   this.inputEl.dom.value = data;
   },
   verificaPhone: function(a) {
	   var b = a.replace(/[\s\(\)\-]/g, ""); 
      
      if (b.length != 10 && b.length != 0)
    	  return false;

      return true;
   }
});