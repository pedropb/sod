/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.window.ReminderWindow', {
    extend: 'Ext.window.Window',
    
    title: 'Lembretes',
	closable: true,
	closeAction: 'destroy',
	
	width: 600,
	height: 400,
	
	modal: true,
	align: 'center',
	layout: 'fit',
	
	items: [{
		xtype: 'form',
		frame: true,
		border: false,
		bodyPadding: 10,
		layout: {
			type: 'vbox',
			align: 'stretch'
		},
		
		defaults: {
			margin: 5
		},
		
		items: [{
    		xtype: 'gtinstructions',
    		height: 40,
    		instructions: [
    		    '- Leia os lembretes',
    		    '- Clique em "Dispensar" para não ser lembrado novamente',
    		    '- Clique em "Próximo" e "Voltar" para navegar entre os lembretes'
    		]
    	},{
			xtype: 'label',
			itemId: 'counter',
			text: 'Lembrete N de N'
		},{
    		xtype: 'textarea',
    		readOnly: true,
    		value: '',
    		flex: 1
    	}]
	}],
	
	buttons: [{
		itemId: 'previousBtn',
		text: 'Voltar',
		handler: function (btn) {
			btn.up('window').previousReminder();
		}
	},{
		itemId: 'dismissBtn',
		text: 'Dispensar',
		handler: function (btn) {
			btn.up('window').dismissReminder();
		}
	},{
		itemId: 'nextBtn',
		text: 'Próximo',
		handler: function (btn) {
			btn.up('window').nextReminder();
		}
	}],
	
    getActiveReminderIndex: function () {
    	return this.activeReminder;
    },
    
    getActiveReminder: function () {
    	return this.reminders[this.activeReminder];
    },
    
    getReminders: function () {
    	return this.reminders;
    },
    
    previousReminder: function () {
    	var me = this;
    	
    	if (me.activeReminder <= 0) {
    		return false;
    	}
    	else {
    		me.activeReminder -= 1;
    		me.updateWindowContent();
    		return true;
    	}
    },
    
    nextReminder: function () {
    	var me = this;
    	
    	if (me.activeReminder >= me.reminders.length - 1) {
    		return false;
    	}
    	else {
    		me.activeReminder += 1;
    		me.updateWindowContent();
    		return true;
    	}
    },
    
    updateWindowContent: function () {
    	var me = this;
    	
    	var reminder = me.getActiveReminder();
    	
    	// Update title with "Lembrete # de ##"
    	me.down('label[itemId=counter]').setText('Lembrete ' + (me.activeReminder + 1) + ' de ' + me.reminders.length);
    	
    	// Update textarea with message content
    	me.down('textarea').setValue(reminder.message);
    	
    	// Update navigation button statuses
    	me.down('button[itemId=nextBtn]').setDisabled(!(me.reminders.length > 1 && me.activeReminder < me.reminders.length - 1));
		me.down('button[itemId=previousBtn]').setDisabled(!(me.reminders.length > 1 && me.activeReminder > 0));
		
		// Update dismiss button status
		me.down('button[itemId=dismissBtn]').setDisabled(me.getActiveReminder().dismissed);
    },
    
    dismissReminder: function () {
		var me = this;
		var reminder = me.getActiveReminder();
		
		Ext.Msg.wait('Dispensando lembrete...', 'Aguarde');
		Ext.Ajax.request({
			url: 'managers/config/reminders.jsp',
			params: {
				id: reminder.id,
				action: 'dismiss'
			},
			success: function (response) {
				var result = Ext.decode(response.responseText);
				if (!result)
					return;
				
				Ext.Msg.hide();
				GeoTech.utils.msg('Sucesso', 'Lembrete dispensado com sucesso.');
				
				reminder.dismissed = true;
				
				if (!me.nextReminder())
					me.updateWindowContent();
				
				if (me.reminders.length == 1)
					me.close();
			},
			failure: GeoTech.utils.prepareServerResponse
		});
    },
    
    afterRender: function () {
    	var me = this;
    	
    	me.callParent(arguments);
    	
    	if (me.reminders.length > 0) {
    		me.activeReminder = 0;
    		me.updateWindowContent();
    	}
    	else {
    		console.log('Erro ao carregar janela de lembretes. Nenhum lembrete foi carregado.');
    	}
    }
});
