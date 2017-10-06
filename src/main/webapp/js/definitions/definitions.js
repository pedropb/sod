GTPlanner.tabs.definitions = {
	formsUrl: 'forms/definitions/definitions.jsp',

	constructor: function (params) {
		return  Ext.create('Ext.ux.GTPanel', {
			title: 'Definições',
			panelMenu: params.panelMenu
		});
	}
};

GTPlanner.forms.listUsers = {
	formsUrl: 'forms/definitions/listUsers.jsp',

	constructor: function (params) {
		return Ext.create('GTPlanner.definitions.UsersGrid', {
			permissions: params
		});
	}
};

GTPlanner.forms.listGroups = {
	formsUrl: 'forms/definitions/listGroups.jsp',

	constructor: function (params) {
		return Ext.create('GTPlanner.definitions.GroupsGrid', {
			permissions: params
		});
	}
};

GTPlanner.forms.listTransactions = {
	formsUrl: 'forms/definitions/listTransactions.jsp',

	constructor: function (params) {
		return Ext.create('GTPlanner.definitions.TransactionsGrid', {
			permissions: params
		});
	}
};

GTPlanner.forms.listActivities = {
	formsUrl: 'forms/definitions/listActivities.jsp',

	constructor: function (params) {
		return Ext.create('GTPlanner.definitions.ActivitiesGrid', {
			permissions: params
		});
	}
};

GTPlanner.forms.listConflicts = {
	formsUrl: 'forms/definitions/listConflicts.jsp',

	constructor: function (params) {
		return Ext.create('GTPlanner.definitions.ConflictsGrid', {
			permissions: params
		});
	}
};

GTPlanner.forms.listModules = {
	formsUrl: 'forms/definitions/listModules.jsp',

	constructor: function (params) {
		return Ext.create('GTPlanner.definitions.ModulesGrid', {
			permissions: params
		});
	}
};

GTPlanner.forms.dataImport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.definitions.ImportDataPanel');
	}
};

GTPlanner.forms.dataExport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.definitions.ExportDataPanel');
	}
};

GTPlanner.forms.dataImportFIDIS = {
	constructor: function (params) {
		return Ext.create('GTPlanner.definitions.ImportDataPanel');
	}
};
