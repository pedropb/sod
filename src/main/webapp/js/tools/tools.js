GTPlanner.tabs.tools = {
	formsUrl: 'forms/tools/tools.jsp',
	
	constructor: function (params) {
		return  Ext.create('Ext.ux.GTPanel', {
			title: 'Ferramentas',
			panelMenu: params.panelMenu
		});
	}
};

GTPlanner.forms.snapshots = {
	formsUrl: 'forms/tools/snapshots.jsp',
	
	constructor: function (params) {
		return Ext.create('GTPlanner.tools.SnapshotsGrid', {
			permissions: params
		});
	}
};

GTPlanner.forms.solveConflicts = {
	formsUrl: 'forms/tools/solveConflicts.jsp',
	
	constructor: function (params) {
		return Ext.create('GTPlanner.tools.SolveConflicts', {
			permissions: params
		});
	}
};

GTPlanner.forms.createGroups = {
	formsUrl: 'forms/tools/createGroups.jsp',
	
	constructor: function (params) {
		return Ext.create('GTPlanner.definitions.GroupsGrid', {
			permissions: params,
			tbar: [{
				text: 'Assistente para criação',
				icon: 'images/wand.png',
				handler: function (btn) {
					Ext.create('GTPlanner.tools.CreateGroupsWindow').show();
				}
			}]
		});
	}
};

GTPlanner.forms.createUsers = {
		formsUrl: 'forms/tools/createUsers.jsp',
		
		constructor: function (params) {
			return Ext.create('GTPlanner.definitions.UsersGrid', {
				permissions: params,
				tbar: [{
					text: 'Assistente para criação',
					icon: 'images/wand.png',
					handler: function (btn) {
						Ext.create('GTPlanner.tools.CreateUsersWindow').show();
					}
				}]
			});
		}
};

GTPlanner.forms.changeLog = {
	formsUrl: 'forms/tools/log.jsp',
	
	constructor: function (params) {
		return Ext.create('GTPlanner.tools.Log', {
			permissions: params
		});
	}
};

GTPlanner.forms.verifyData = {
	constructor: function (params) {
		return Ext.create('GTPlanner.tools.VerifyDataPanel');
	}
};

GTPlanner.forms.myAccessDemands = {
	constructor: function (params) {
		return Ext.create('GTPlanner.tools.MyAccessDemandsGrid', {
		});
	}
};

GTPlanner.forms.accessDemands = {
	formsUrl: 'forms/tools/accessDemands.jsp',
	
	constructor: function (params) {
		return Ext.create('GTPlanner.tools.AccessDemandsGrid', {
			permissions: params
		});
	}
};