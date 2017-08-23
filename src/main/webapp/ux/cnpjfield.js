/*
 * ExtJS User Extension - CNPJField
 * Adaptado por Pedro Baracho 
 * pedropbaracho@gmail.com
 * 
 * Funções de verificaçãoo de CNPJ escritas por Ext JS BR Forum
 * Fonte: http://www.extjs.com.br/forum/index.php?topic=5124.0
 */
Ext.define('Ux.CnpjField', {
   extend: 'Ext.form.field.Text',
   alias: ['widget.cnpjfield'],

   autocomplete: "off",

   initComponent: function(){
      var me = this;

      Ext.apply(Ext.form.VTypes, {
         cnpj: function(b, a) {
            return me.verificaCNPJ(b);
         },
         cnpjText: "CNPJ inválido."
      });

      Ext.apply(me, { vtype: 'cnpj' });

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
	   
	   // Filling in extra spaces until data has 14 "digits"
	   for (var i=data.length; i < 14; i++)
		   data += " ";
	   
	   // Formatting CNPJ 00.000.000/0000-00
	   data = (data.substr(0,2) + "." + data.substr(2,3) + "." + data.substr(5,3) + "/" + data.substr(8,4) + "-" + data.substr(12,2));
	   
	   this.inputEl.dom.value = data;
	   
	   this.fireEvent('format', this, data);
   },
   verificaCNPJ: function(a) {
      var me = this;
      if (a == "") return true;

      a = a.replace(/\D/g, "");
      a = a.replace(/^\s+/, "");
      if (parseInt(a, 10) == 0) {
         return false;
      } else {
         g = a.length - 2;
         if (me.testaCNPJ(a, g) == 1) {
            g = a.length - 1;
            if (me.testaCNPJ(a, g) == 1) {
               return true;
            } else {
               return false;
            }
         } else {
            return false;
         }
      }
   },
   testaCNPJ: function(a, d) {
      var b = 0;
      var e = 2;
      var f;
      for (f = d; f > 0; f--) {
         b += parseInt(a.charAt(f - 1),10) * e;
         if (e > 8) {
            e = 2;
         } else {
            e++;
         }
      }
      b %= 11;
      if (b == 0 || b == 1) {
         b = 0;
      } else {
         b = 11 - b;
      }
      if (b != parseInt(a.charAt(d),10)) {
         return (0);
      } else {
         return (1);
      }
   }
});