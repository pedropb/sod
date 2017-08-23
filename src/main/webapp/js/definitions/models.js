Ext.define('UserModel', {
	extend: 'Ext.data.Model',
	fields: [
		{name: 'id', 			type: 'string'},
		{name: 'name', 			type: 'string'},
		{name: 'created', 		type: 'date',		dateFormat: 'Y-m-d H:i:s.u'}
	]}
);

Ext.define('GroupModel', {
	extend: 'Ext.data.Model',
	fields: [
	    {name: 'id', 			type: 'string'},
	    {name: 'name',	 		type: 'string'},
	    {name: 'created',		type: 'date',		dateFormat: 'Y-m-d H:i:s.u'}
	]
});

Ext.define('TransactionModel', {
	extend: 'Ext.data.Model',
	fields: [
	    {name: 'id', 				type: 'string'},
	    {name: 'name',	 			type: 'string'},
	    {name: 'activity_id',		type: 'string'},
	    {name: 'activity',	 		type: 'string'},
	    {name: 'user_transaction',	type: 'boolean'},
	    {name: 'created',			type: 'date',		dateFormat: 'Y-m-d H:i:s.u'}
	]
});

Ext.define('ModuleModel', {
	extend: 'Ext.data.Model',
	fields: [
	    {name: 'id', 			type: 'string'},
	    {name: 'name',	 		type: 'string'},
	    {name: 'created',		type: 'date',		dateFormat: 'Y-m-d H:i:s.u'}
	]
});

Ext.define('ActivityModel', {
	extend: 'Ext.data.Model',
	fields: [
	    {name: 'id', 			type: 'string'},
	    {name: 'name',	 		type: 'string'},
	    {name: 'created',		type: 'date',		dateFormat: 'Y-m-d H:i:s.u'}
	]
});

Ext.define('ConflictModel', {
	extend: 'Ext.data.Model',
	fields: [
	    {name: 'id', 			type: 'string'},
	    {name: 'name',	 		type: 'string'},
	    {name: 'activity1_id',	type: 'string'},
	    {name: 'activity1',		type: 'string'},
	    {name: 'activity2_id',	type: 'string'},
	    {name: 'activity2',		type: 'string'},
	    {name: 'created',		type: 'date',		dateFormat: 'Y-m-d H:i:s.u'}
	]
});