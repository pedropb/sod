Ext.define('ReportModel', {
	extend: 'Ext.data.Model',
	fields: [
        {name: 'id', 			type: 'string'},
        {name: 'name', 			type: 'string'},
		{name: 'quantity', 		type: 'int'}
	]}
);

Ext.define('SolutionsDetailReportModel', {
	extend: 'Ext.data.Model',
	fields: [
        {name: 'conflict_id', 				type: 'string'},
        {name: 'conflict', 			type: 'string'},
        {name: 'activity1_id', 				type: 'string'},
        {name: 'activity1', 			type: 'string'},
        {name: 'activity2_id', 				type: 'string'},
        {name: 'activity2', 			type: 'string'},
        {name: 'reference_id', 				type: 'string'},
        {name: 'reference', 			type: 'string'}
	]}
);

Ext.define('SolutionsGeneralReportModel', {
	extend: 'Ext.data.Model',
	fields: [
	    {name: 'target_id', 				type: 'string'},
		{name: 'name', 						type: 'string'},
		{name: 'conflict', 					type: 'string'},
		{name: 'activity1', 				type: 'string'},
		{name: 'activity2', 				type: 'string'},
		{name: 'description', 				type: 'string'},
		{name: 'user', 						type: 'string'},
		{name: 'created', 					type: 'date', 		dateFormat: 'Y-m-d H:i:s.u'}
	]}
);