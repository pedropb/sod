// Implementando trim para Internet Explorer
if(typeof String.prototype.trim !== 'function') {
	String.prototype.trim = function() {
		return this.replace(/^\s+|\s+$/g, ''); 
	};
}

Ext.override(Ext.form.NumberField, {
	decimalSeparator: ',',
	getSubmitValue: function () {
		var me = this;
		var v = me.getValue();
		
		if (typeof(v) == 'string') {
			return v.replace(me.decimalSeparator, '.');
		}
		else if (typeof(v) == 'number') { 
			return v.toFixed(me.decimalPrecision).replace(me.decimalSeparator, '.');
		}
		else {
			return '';
		}
		
	}
});

// Implementando indexOf para Internet Explorer
if(!Array.prototype.indexOf){Array.prototype.indexOf=function(searchElement){"use strict";if(this==null){throw new TypeError();} var t=Object(this);var len=t.length>>>0;if(len===0){return-1;} var n=0;if(arguments.length>0){n=Number(arguments[1]);if(n!=n){n=0;}else if(n!=0&&n!=Infinity&&n!=-Infinity){n=(n>0||-1)*Math.floor(Math.abs(n));}} if(n>=len){return-1;} var k=n>=0?n:Math.max(len-Math.abs(n),0);for(;k<len;k++){if(k in t&&t[k]===searchElement){return k;}} return-1;};}

// ExtJS 4.1.0 Fixes
if (Ext.versions.extjs.version == "4.1.0") {
	Ext.override(Ext.AbstractComponent, {
	    addCls : function(cls) {
		    var me = this,
		        el = me.rendered ? me.el : me.protoEl;
		
		    if (el && typeof el.addCls == 'function')
		    	el.addCls.apply(el, arguments);
		    return me;
		}
	});
	
	Ext.override(Ext.chart.Legend, {
		createItems: function() {
	        var me = this,
	            chart = me.chart,
	            items = me.items,
	            padding = me.padding,
	            itemSpacing = me.itemSpacing,
	            spacingOffset = 2,
	            maxWidth = 0,
	            maxHeight = 0,
	            totalWidth = 0,
	            totalHeight = 0,
	            vertical = me.isVertical,
	            math = Math,
	            mfloor = math.floor,
	            mmax = math.max,
	            i = 0, 
	            len = items ? items.length : 0,
	            spacing = 0,
	            item, bbox, height, width;
	
	        
	        if (len) {
	            for (; i < len; i++) {
	                items[i].destroy();
	            }
	        }
	        
	        items.length = [];
	        
	        
	        chart.series.each(function(series, i) {
	            if (series.showInLegend) {
	                Ext.each([].concat(series.yField), function(field, j) {
	                    item = Ext.create('Ext.chart.LegendItem', {
	                        legend: this,
	                        series: series,
	                        surface: chart.surface,
	                        yFieldIndex: j
	                    });
	                    bbox = item.getBBox();
	
	                    
	                    width = bbox.width; 
	                    height = bbox.height;
	
	                    if (i + j === 0) {
	                        spacing = vertical ? padding + height / 2 : padding;
	                    }
	                    else {
	                        spacing = itemSpacing / (vertical ? 2 : 1);
	                    }
	                    
	                    item.x = mfloor(vertical ? padding : totalWidth + spacing) - (me.userWidth ? (me.userWidth - me.width) : 0);
	                    item.y = mfloor(vertical ? totalHeight + spacing : padding + height / 2);
	
	                    
	                    totalWidth += width + spacing;
	                    totalHeight += height + spacing;
	                    maxWidth = mmax(maxWidth, width);
	                    maxHeight = mmax(maxHeight, height);
	
	                    items.push(item);
	                }, this);
	            }
	        }, me);
	
	        
	        me.width = mfloor((vertical ? maxWidth : totalWidth) + padding * 2);
	        if (vertical && items.length === 1) {
	            spacingOffset = 1;
	        }
	        me.height = mfloor((vertical ? totalHeight - spacingOffset * spacing : maxHeight) + (padding * 2));
	        me.itemHeight = maxHeight;
	    },
    
		getBBox: function() {
	        var me = this;
	        
	        return {
	            x: (Math.round(me.x) - me.boxStrokeWidth / 2) - (me.userWidth ? (me.userWidth - me.width) : 0),
	            y: Math.round(me.y) - me.boxStrokeWidth / 2,
	            width: me.userWidth ? me.userWidth : me.width,
	            height: me.height
	        };
	    }
	});
}

if (Ext.versions.extjs.version == "4.2.0.663") {
	// Bug reported at: http://www.sencha.com/forum/showthread.php?261451
	// Date: 2013-04-16
	Ext.override(Ext.form.FieldSet, {
	    applyState: function(state) {
	    	var me = this;
	    	
	    	if (state) {
	    		if (state.collapsed === true) {
	    			me.collapse();
	    		}
	    		else if (state.collapsed === false) {
	    			me.expand();
	    		}
	    	}
	    	
	    	me.callParent(arguments);
		}
	});
	
	// Bug reported at: http://www.sencha.com/forum/showthread.php?258397
	// Date: 2013-03-11
	Ext.override(Ext.selection.Model, {
	    storeHasSelected: function(record) {
	        var store = this.store,
	            records,
	            len, id, i;
	        
	        if (record.hasId() && store.getById(record)) {
	            return true;
	        } else {
	            records = store.data.items;
	            len = records ? records.length : 0;
	            id = record.internalId;
	            
	            for (i = 0; i < len; ++i) {
	                if (id === records[i].internalId) {
	                    return true;
	                }
	            }
	        }
	        return false;
	    }
	});
	
	Ext.override(Ext.data.Store, {
		each: function (fn, scope) {
			var data = this.data.items;
			
			if (!data)
				data = [this.data.first];
			
            var dLen = data.length,
            record, d;

	        for (d = 0; d < dLen; d++) {
	            record = data[d];
	            if (fn.call(scope || record, record, d, dLen) === false) {
	                break;
	            }
	        }
		}
	});
	
	
}

delete Ext.tip.Tip.prototype.minWidth;

if(Ext.isIE10) { 
    Ext.supports.Direct2DBug = true;
}