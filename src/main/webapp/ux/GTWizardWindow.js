/*
 * GTWizardWindow
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 * 
 * A basic window with Next and Previous buttons implemented
 */
Ext.define('Ext.ux.GTWizardWindow', {
    extend: 'Ext.window.Window',
    alias: ['widget.gtwizardwindow'],
    
    layout: 'card',
    
    activeCard: 0,
    animateTransitions: true,
    
    buttons: [{
    	text: 'Anterior',
    	hidden: true,
    	handler: function (btn) {
    		var me = btn.up('window');
    		
    		me.previousCard();
    	}
    },{
    	text: 'Próximo',
    	handler: function (btn) {
    		var me = btn.up('window');
    		
    		me.nextCard();
    	}
    },{
    	text: 'Concluir',
    	hidden: true,
    	handler: function (btn) {
    		var me = btn.up('window');
    		
    		if (me.finishFn(me))
    			me.close();
    	}
    }],
    
    previousCard: function () {
    	var me = this;
    	
    	var layout = me.getLayout();
    	
    	var card = layout.getActiveItem(); 
    	if (card.fireEvent('beforeprevious', card, me)) {
    		layout.setActiveItem(--me.activeCard);
        	me.activeCard = me.items.indexOf(layout.getActiveItem());
        	
        	card = layout.getActiveItem();
        	if (me.animateTransitions) {
        		var animateCfg = {};
        		if (typeof(card.width) == "number") {
        			animateCfg.width = card.width + 12;
        		}
        		
        		if (typeof(card.height) == "number") {
        			animateCfg.height = card.height + 61;
        		}
        		
        		if (animateCfg.width || animateCfg.height) {
        			me.setLoading(true);
        			me.animate({
            			to: animateCfg,
            			listeners: {
            				afteranimate: function () {
            					me.setLoading(false);
            				}
            			}
            		});
        		}
        	}
        	
        	card.fireEvent('previous', card, me);
        	
        	var tb = me.getDockedItems('toolbar[dock=bottom]')[0];
        	tb.items.items[1].setVisible(true);
        	tb.items.items[2].setVisible(false);
        	
        	if (me.activeCard == 0) {
        		tb.items.items[0].setVisible(false);
        	}
    	}
    },
    
    nextCard: function () {
    	var me = this;
    	
    	var layout = me.getLayout();
    	
    	var card = layout.getActiveItem(); 
    	if (card.fireEvent('beforenext', card, me)) {
    		layout.setActiveItem(++me.activeCard);
        	me.activeCard = me.items.indexOf(layout.getActiveItem());
        	
        	card = layout.getActiveItem();
        	if (me.animateTransitions) {
        		var animateCfg = {};
        		if (typeof(card.width) == "number") {
        			animateCfg.width = card.width + 12;
        		}
        		
        		if (typeof(card.height) == "number") {
        			animateCfg.height = card.height + 61;
        		}
        		
        		if (animateCfg.width || animateCfg.height) {
        			me.setLoading(true);
        			me.animate({
            			to: animateCfg,
            			listeners: {
            				afteranimate: function () {
            					me.setLoading(false);
            				}
            			}
            		});
        		}
        	}
        	
        	card.fireEvent('next', card, me);
        	
        	var tb = me.getDockedItems('toolbar[dock=bottom]')[0];
        	tb.items.items[0].setVisible(true);
        	if (me.activeCard == me.items.length - 1) {
        		tb.items.items[1].setVisible(false);
        		tb.items.items[2].setVisible(true);
        	}
        	else {
        		tb.items.items[1].setVisible(true);
        		tb.items.items[2].setVisible(false);
        	}
    	}
    },
    
    /*
     * These can be used to provide validation
     * when finishing the wizard.
     */
    disableNext: function (enable) {
    	var me = this;
    	
    	var tb = me.getDockedItems('toolbar[dock=bottom]')[0];
		tb.items.items[1].setDisabled(!enable);
    },

    hideNext: function (show) {
    	var me = this;
    	
    	var tb = me.getDockedItems('toolbar[dock=bottom]')[0];
		tb.items.items[1].setVisible(!show);
    },
    
    disablePrevious: function (enable) {
    	var me = this;
    	
    	var tb = me.getDockedItems('toolbar[dock=bottom]')[0];
		tb.items.items[0].setDisabled(!enable);
    },
    
    hidePrevious: function (show) {
    	var me = this;
    	
    	var tb = me.getDockedItems('toolbar[dock=bottom]')[0];
		tb.items.items[0].setVisible(!show);
    },
    
    disableFinish: function (enable) {
    	var me = this;
    	
    	var tb = me.getDockedItems('toolbar[dock=bottom]')[0];
		tb.items.items[2].setDisabled(!enable);
    },
    
    hideFinish: function (show) {
    	var me = this;
    	
    	var tb = me.getDockedItems('toolbar[dock=bottom]')[0];
		tb.items.items[2].setVisible(!show);
    },
    
    /*
     * This method should be overrided to provide functionality
     * when finishing the wizard.
     */
    finishFn: function (win) {
    	
    }
});
