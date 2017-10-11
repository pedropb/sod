<%@page import="alttus.reminders.ReminderController"%>
<%@page import="java.util.Calendar"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="includes/getRevisionNumber.jsp" %>
<%
	final String revision = getRevisionNumber();
%>
<%
if (session.getAttribute("userId") == null)
{
	response.sendRedirect("index.jsp");
 	return;
}

String userId = (String) session.getAttribute("userId");

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="CACHE-CONTROL" content="NO-CACHE" />
<meta http-equiv="expires" content="-1" />
<link rel="shortcut icon" href="images/favicon.ico" />
<title>SOD</title>
 
<!-- ExtJS -->
<link rel="stylesheet" type="text/css" href="ext-4.2/resources/css/ext-all-gray.css" />
<script type="text/javascript" src="ext-4.2/ext-all-debug.js" charset="UTF-8"></script>
<script type="text/javascript" src="ext-4.2/locale/ext-lang-pt_BR-utf8.js" charset="UTF-8"></script>

<!-- GeoTech Utils -->
<script type="text/javascript" src="utils/geotech_browser_fixes.js?_dc=<%=revision%>" charset="UTF-8"></script>
<script type="text/javascript" src="utils/geotech_utils.js?_dc=<%=revision%>" charset="UTF-8"></script>

<!-- CSS -->
<link rel="stylesheet" type="text/css" href="css/base.css" />	
<link rel="stylesheet" type="text/css" href="css/geotech_utils.css" />
<link rel="stylesheet" type="text/css" href="css/gtgrid.css" />
<link rel="stylesheet" type="text/css" href="css/gtgridbox.css" />
<link rel="stylesheet" type="text/css" href="css/gtpanel.css" />
<link rel="stylesheet" type="text/css" href="css/CheckHeader.css" />

<!-- UX -->
<script type="text/javascript" src="ux/GTGridBox.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTPanel.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTTabbedApp.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTMenuItem.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTMoneyField.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/cnpjfield.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/phonefield.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/cepfield.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/cpffield.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTFilterWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTCheckboxGroup.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTReportPanel.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/CheckColumn.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTWizard.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTWizardWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTInstructions.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTStore.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/GTPermissions.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="ux/uppertextfield.js?_dc=<%=revision%>"></script>

<script type="text/javascript" src="js/App.jsp"></script>

<!-- UI -->
<script type="text/javascript" src="js/config/config.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/config/models.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/config/stores.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/config/GruposPermissoesGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/config/GruposPermissoesWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/config/UsuariosGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/config/UsuariosWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/config/AlterarSenhaWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/config/RemindersGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/config/ReminderWindow.js?_dc=<%=revision%>"></script>

<script type="text/javascript" src="js/definitions/definitions.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/models.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/stores.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/UsersGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/UsersWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/GroupsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/GroupsWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/ActivitiesGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/ActivitiesWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/ConflictsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/ConflictsWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/ModulesGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/ModulesWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/TransactionsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/TransactionsWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/ImportDataPanel.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/ImportFIDISDataPanel.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/definitions/ExportDataPanel.js?_dc=<%=revision%>"></script>

<script type="text/javascript" src="js/reports/models.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/stores.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/reports.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/Chart.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/SummaryGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/UsersGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/GroupsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/TransactionsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/ActivitiesGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/ModulesGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/ConflictsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/UsersSolutionsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/GroupsSolutionsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/reports/SolutionsGeneralGrid.js?_dc=<%=revision%>"></script>

<script type="text/javascript" src="js/dashboard/dashboard.js?_dc=<%=revision%>"></script>

<script type="text/javascript" src="js/tools/tools.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/models.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/stores.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/SnapshotsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/SolveConflictsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/SolveConflictsWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/CreateGroupsWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/CreateUsersWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/LogGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/VerifyDataPanel.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/MyAccessDemandsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/AccessDemandsWindow.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/AccessDemandsGrid.js?_dc=<%=revision%>"></script>
<script type="text/javascript" src="js/tools/ChangeDemandStatusWindow.js?_dc=<%=revision%>"></script>

<!-- UI -->
<script type="text/javascript">
<%@include file="includes/timeout.jsp"%>

	Ext.state.Manager.setProvider(new Ext.state.CookieProvider());

	Ext.override(Ext.form.NumberField, {
		decimalSeparator: ',',
		keyNavEnabled: false,
		mouseWheelEnabled: false,
		hideTrigger: true
	});
	
	Ext.override(Ext.form.DateField, {
		format: 'd/m/Y',
		altFormats: 'd/m/Y|j/n/Y|j/n/y|j/m/y|d/n/y|j/m/Y|d/m/Y|d-m-y|d-m-Y|d/m|d-m|dm|dmy|dmY|d|d-m-Y'
	});
	
	Ext.override(Ext.ux.GTMoneyField, { decimalSeparator: ',' });

	Ext.override(Ext.grid.Panel, { bodyStyle: 'min-height: 100px;' });
	
	Ext.override(Ext.ux.GTGrid, { xlsExportAction: 'actions/exportXls.jsp' });

	Ext.override(Ext.window.Window, {
		constrain: true,
		modal:true
	});
	
	Ext.override(Ext.data.Connection, {
        timeout: 3600000
	});
	
	/*
	 * Override to allow multiple setLoading for the same component
	 */
	Ext.override(Ext.Component, {
	    setLoading : function(load, targetEl) {
	    	
	    	
	    	var me = this,
	            config;
	    	
	    	if (typeof(me.loadCount) != "number") {
	    		me.loadCount = 0;
	    	}
	    	
	    	if (load !== false) {
	    		me.loadCount += 1;
	    	}
	    	else {
	    		me.loadCount -= 1;
	    	}
	    	
	        if (me.rendered) {
	        	if (me.loadCount == 0) {
	        		Ext.destroy(me.loadMask);
		            me.loadMask = null;
	        	}
	        	else {
	        		if (load !== false && !me.collapsed) {
	        			Ext.destroy(me.loadMask);
			            me.loadMask = null;
			            
		                if (Ext.isObject(load)) {
		                    config = Ext.apply({}, load);
		                } else if (Ext.isString(load)) {
		                    config = {msg: load};
		                } else {
		                    config = {};
		                }
		                if (targetEl) {
		                    Ext.applyIf(config, {
		                        useTargetEl: true
		                    });
		                }
		                me.loadMask = new Ext.LoadMask(me, config);
		                me.loadMask.show();
		            }
	        	}
	        }
	        return me.loadMask;
        }
	});
	
		
	Ext.onReady(function()
	{
		Ext.History.init();
		GTPlanner.init();
		
		GTPlanner.user = <% out.print("'" + userId + "'"); %>;
		GTPlanner.date = <% Calendar d = Calendar.getInstance(); out.print("new Date("+ d.get(Calendar.YEAR) + ", " + d.get(Calendar.MONTH) + ", " + d.get(Calendar.DAY_OF_MONTH) +")"); %>;

<%
	ReminderController rc = new ReminderController();

	if (rc.hasReminders(userId)) {
%>
		Ext.create('GTPlanner.window.ReminderWindow', {
			reminders: <% out.print(rc.getRemindersJSON(userId)); %>
		}).show();
<%
	}
%>

		
	});
</script>
</head>

<body>
	<div id="msg-div"><div id="msg-ct"></div></div>
</body>
</html>