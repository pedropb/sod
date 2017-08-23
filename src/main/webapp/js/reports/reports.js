GTPlanner.tabs.reports = {
	formsUrl: 'forms/reports/reports.jsp',
	
	constructor: function (params) {
		return  Ext.create('Ext.ux.GTPanel', {
			title: 'Relatórios',
			panelMenu: params.panelMenu
		});
	}
};

GTPlanner.forms.summaryReport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.reports.SummaryGrid');
	}
};

GTPlanner.forms.usersReport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.reports.UsersGrid');
	}
};

GTPlanner.forms.groupsReport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.reports.GroupsGrid');
	}
};

GTPlanner.forms.transactionsReport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.reports.TransactionsGrid');
	}
};

GTPlanner.forms.activitiesReport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.reports.ActivitiesGrid');
	}
};

GTPlanner.forms.modulesReport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.reports.ModulesGrid');
	}
};

GTPlanner.forms.conflictsReport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.reports.ConflictsGrid');
	}
};

GTPlanner.forms.usersSolutionsReport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.reports.UsersSolutionsGrid');
	}
};

GTPlanner.forms.usersSolutionsGeneralReport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.reports.SolutionsGeneralGrid', {
			groupBy: 'Usuário'
		});
	}
};

GTPlanner.forms.groupsSolutionsReport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.reports.GroupsSolutionsGrid');
	}
};

GTPlanner.forms.groupsSolutionsGeneralReport = {
	constructor: function (params) {
		return Ext.create('GTPlanner.reports.SolutionsGeneralGrid', {
			groupBy: 'Grupo'
		});
	}
};