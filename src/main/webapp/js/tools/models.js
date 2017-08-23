Ext.define('SnapshotModel', {
	extend: 'Ext.data.Model',
	fields: [
		{name: 'id', 						type: 'int'},
		{name: 'users_conflicts', 			type: 'int'},
		{name: 'accepted_users_conflicts', 	type: 'int'},
		{name: 'groups_conflicts', 			type: 'int'},
		{name: 'accepted_groups_conflicts', type: 'int'},
		{name: 'created', 					type: 'date',		dateFormat: 'Y-m-d H:i:s.u'}
	]}
);

Ext.define('SolveConflictModel', {
	extend: 'Ext.data.Model',
	fields: [
		{name: 'name', 						type: 'string'},
		{name: 'conflict', 					type: 'string'},
		{name: 'activity1', 				type: 'string'},
		{name: 'activity2', 				type: 'string'},
		{name: 'user_id', 					type: 'string'},
		{name: 'conflict_id', 				type: 'string'},
		{name: 'group_id', 					type: 'string'},
	    {name: 'accepted', 					type: 'boolean'},
	    {name: 'reason', 					type: 'string'},
	    {name: 'reason_created',			type: 'string'},
	    {name: 'gt_user', 					type: 'string'}
	]}
);

Ext.define('SolveConflictDataModel', {
	extend: 'Ext.data.Model',
	fields: [
	    {name: 'id', 						type: 'string'},
	    {name: 'name', 						type: 'string'}
	]}
);

Ext.define('LogModel', {
	extend: 'Ext.data.Model',
	fields: [
		{name: 'id', 						type: 'int'},
		{name: 'user', 						type: 'string'},
		{name: 'operation', 				type: 'string'},
		{name: 'module', 					type: 'string'},
		{name: 'description', 				type: 'string'},
		{name: 'form', 						type: 'string'},
		{name: 'created', 					type: 'date', 		dateFormat: 'Y-m-d H:i:s.u'}
	]}
);

Ext.define('AccessDemandModel', {
	extend: 'Ext.data.Model',
	fields: [
		{name: 'id', 						type: 'int'},
		{name: 'status', 					type: 'string'},
		{name: 'created', 					type: 'date', 		dateFormat: 'Y-m-d H:i:s.u'},
		{name: 'real_name', 				type: 'string'},
		{name: 'user_name', 				type: 'string'},
		{name: 'applicant', 				type: 'string'},
		{name: 'demand_type', 				type: 'string'},
		{name: 'group1', 					type: 'string'},
		{name: 'access_level1', 			type: 'string'},
		{name: 'group2', 					type: 'string'},
		{name: 'access_level2', 			type: 'string'},
		{name: 'group3', 					type: 'string'},
		{name: 'access_level3', 			type: 'string'},
		{name: 'copy_user_id', 				type: 'string'},
		{name: 'obs', 						type: 'string'},
		{name: 'updated', 					type: 'date', 		dateFormat: 'Y-m-d H:i:s.u'},
		{name: 'approver', 					type: 'string'},
		{name: 'reason', 					type: 'string'}
	]}
);