/*
 * ExtJS User Extension - CPFField
 * Desenvolvido por Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('Ux.CpfField', {
   extend: 'Ext.form.field.Text',
   alias: ['widget.cpffield'],

   autocomplete: "off",

   initComponent: function(){
      var me = this;

      Ext.apply(Ext.form.VTypes, {
         cpf: function(b, a) {
            return me.verificaCPF(b);
         },
         cpfText: "CPF inválido."
      });

      Ext.apply(me, { vtype: 'cpf' });

      me.callParent(arguments);
   },
   initEvents: function() {
      var me = this;
      
      me.on('focus', me.clearMask);
      me.on('blur', me.initMask);

      me.callParent(arguments);
   },
   maskRe: /[0-9]/,
   clearMask: function() {
	   this.inputEl.dom.value = this.inputEl.dom.value.replace(/[\s\.\/\-]/g, "");
   },
   initMask: function() {
	   var data = this.inputEl.dom.value;

	   data = data.replace(/[\s\.\/\-]/g, "");
	   
	   if (data.length == 0)
		   return;
	   
	   // Filling in extra spaces until data has 11 "digits"
	   for (var i=data.length; i < 11; i++)
		   data += " ";
	   
	   // Formatting CPF 000.000.000-00
	   data = (data.substr(0,3) + "." + data.substr(3,3) + "." + data.substr(6,3) + "-" + data.substr(9,2));
	   
	   this.inputEl.dom.value = data;
   },
   verificaCPF: function(a) {
      var me = this;
      if (a == "") return true;

      a = a.replace(/\D/g, "");
      a = a.replace(/^\s+/, "");
      if (parseInt(a, 10) == 0) {
         return false;
      } else {
    	  g = a.length - 2;
          if (me.testaCPF(a, g) == 1) {
             g = a.length - 1;
             if (me.testaCPF(a, g) == 1) {
                return true;
             } else {
                return false;
             }
          } else {
             return false;
          }
      }
   },
   testaCPF: function(a, d) {
		var b = 0;
		var i;
		for (i = 0; i < 9; i++)
			b += parseInt(a.charAt(i)) * (10 - i);
		var e = 11 - (b % 11);
		if (e == 10 || e == 11)
			e = 0;
		if (e != parseInt(a.charAt(9)))
			return false;
		b = 0;
		for (i = 0; i < 10; i++)
			b += parseInt(a.charAt(i)) * (11 - i);
		e = 11 - (b % 11);
		if (e == 10 || e == 11)
			e = 0;
		if (e != parseInt(a.charAt(10)))
			return 0;
		return 1;
   }
});