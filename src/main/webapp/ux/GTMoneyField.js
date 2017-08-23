/*
 * ExtJS User Extension - GTMoneyField
 * Desenvolvido por Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('Ext.ux.GTMoneyField', {
	extend: 'Ext.form.field.Text',
	alias: ['widget.moneyfield'],

	autocomplete: "off",
	
	decimalSeparator: '.',

	minText: 'Valor inválido!',
	maxText: 'Valor inválido!',
	isMasked: false,
	
	validator: function () {
		var me = this;
		
		var value = me.getSubmitValue();

		if (typeof(me.minValue) == 'number' && value < me.minValue)
			return me.minText;
		
		if (typeof(me.maxValue) == 'number' && value > me.maxValue)
			return me.maxText;
		
		return true;
	},
	
	validateOnChange: false,
	
	initComponent: function () {
		var me = this;
		me.maskRe = new RegExp('['+ (me.minValue >= 0 ? '' : '\-') +'0-9' + me.decimalSeparator + ']');
		
		me.callParent();
	},
	
	afterRender: function () {
		var me = this;
		
		me.initMask();

		me.callParent();
	},

	onBlur: function () {
		var me = this;
		
		if (!this.readOnly)
			me.initMask();
		
		me.callParent();
	},

	onFocus: function () {
		if (this.fieldLabel == 'Férias')
			console.log('Focus');
		
		if (!this.readOnly)
			this.clearMask();
		this.callParent();
	},

	clearMask: function() {
		var me = this;
		var regex = new RegExp('\-?[0-9]*'+ (me.decimalSeparator == "." ? "\." : me.decimalSeparator) +'?[0-9]*');
		var cRegex = new RegExp('[^\-0-9' + (me.decimalSeparator == "." ? "\." : me.decimalSeparator) + ']', 'g');
		
		if (me && me.inputEl && me.inputEl.dom && me.inputEl.dom.value && me.isMasked) {
			me.inputEl.dom.value = me.inputEl.dom.value.replace(cRegex, "").match(regex)[0];
			me.isMasked = false;
		}
			
	},

	initMask: function() {
		var me = this;
		
		if (me && me.inputEl && me.inputEl.dom && !me.isMasked) {
			var data = me.inputEl.dom.value;

			data = GeoTech.utils.renderers.money(data.replace(me.decimalSeparator, "."));

			me.inputEl.dom.value = data;
			
			me.isMasked = true;
		}
	},
	
	getSubmitValue: function () {
		return this.getFloatValue();
	},
	
	getFloatValue: function () {
		var me = this;

		if (me.inputEl != null && me.inputEl.dom != null){
			me.clearMask();
			var data = me.inputEl.dom.value.replace(me.decimalSeparator, ".");
			me.initMask();
			
			data = parseFloat(data);
			return (isNaN(data) ? 0.0 : data);
		}
		else
			return null;
	},
	
	setFloatValue: function (value) {
		var me = this;
		
		value = parseFloat(value);
		
		if (!isNaN(value)) {
			me.inputEl.dom.value = GeoTech.utils.renderers.money(value);
			me.isMasked = true;
		}
		
		return me;
	}
});