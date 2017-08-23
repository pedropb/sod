Ext.define('UsuarioModel', {
	extend: 'Ext.data.Model',
	fields: [
		{name: 'id', 			type: 'int'},
		{name: 'login', 		type: 'string'},
		{name: 'ativo', 		type: 'boolean'},
		{name: 'grupo', 		type: 'int'}
	]}
);

Ext.define('GrupoPermissoesModel', {
	extend: 'Ext.data.Model',
	fields: [
	    {name: 'id', 			type: 'int'},
	    {name: 'grupo',	 		type: 'string'},
	    {name: 'descricao',		type: 'string'}
	]
});

Ext.define('ReminderModel', {
	extend: 'Ext.data.Model',
	fields: [
	    {name: 'id', 			type: 'int'},
	    {name: 'message',	 	type: 'string'},
	    {name: 'created',		type: 'date',		dateFormat: 'Y-m-d H:i:s.u'},
	    {name: 'next_alarm',	type: 'date',		dateFormat: 'Y-m-d'},
	    {name: 'last_viewed',	type: 'date',		dateFormat: 'Y-m-d'},
	    {name: 'recipient',	 	type: 'string'},
	    {name: 'author',	 	type: 'string'},
	    {name: 'dismissed',	 	type: 'boolean'},
	    {name: 'repeat',	 	type: 'int'}
	]
});