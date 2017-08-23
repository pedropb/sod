GTPlanner.tabs.config = {
	formsUrl: 'forms/config/config.jsp',
	
	constructor: function (params) {
		return  Ext.create('Ext.ux.GTPanel', {
			title: 'Configurações',
			panelMenu: params.panelMenu
		});
	}
};

GTPlanner.forms.listaUsuarios = {
	formsUrl: 'forms/config/listaUsuarios.jsp',
	
	constructor: function (params) {
		return Ext.create('GTPlanner.grid.Usuarios', {
			ajaxParams: params
		});
	}
};

GTPlanner.forms.listaGruposPermissoes = {
	formsUrl: 'forms/config/listaGruposPermissoes.jsp',
	
	constructor: function (params) {
		return Ext.create('GTPlanner.grid.GruposPermissoes', {
			ajaxParams: params
		});
	}
};

GTPlanner.forms.listaLembretes = {
	formsUrl: 'forms/config/reminders.jsp',
	
	constructor: function (params) {
		return Ext.create('GTPlanner.config.Reminders', {
			ajaxParams: params
		});
	}
};

GTPlanner.forms.panelAlterarSenha = {
	constructor: function (params) {
		Ext.create('GTPlanner.window.AlterarSenha').show();
	}
};