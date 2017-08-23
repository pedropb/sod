Ext.define('Ext.ux.GTMenuItem', {

	extend: 'Ext.container.Container',
	alias: ['widget.gtmenuitem'],

	defaultSymbol: '-',
	
	constructor: function (config) {
		var me = this;

		me.initConfig(config);
		
		var width = (config.width ? config.width : 295);
		var height = (config.height ? config.height : 185);
		var padding = config.padding ? config.padding : '15 22 22 15';
		var iconWidth = (config.iconWidth ? config.iconWidth : 77);
		var iconHeight = (config.iconHeight ? config.iconHeight : 77);
		var background = (config.background ? config.background : 'background-image:url(images/caixas-conteudo.png)');
		var descriptionColumns = (config.descriptionColumns ? config.descriptionColumns : 2);
		var descriptionArr = (config.description ? config.description : []);
		var items = new Array();
		for (var i=0; i<descriptionArr.length; i++)
			items.push({
				html: me.defaultSymbol+' '+descriptionArr[i]
			});
		
		Ext.apply(me, {
			width: width,
			height: height,
			padding: padding,
			margin: '20 20 20 20',
			title: '',
			style: background + "; background-repeat:no-repeat; cursor: pointer;",
			border: false,
			items: [{
				xtype: 'component',
				width: iconWidth,
				height: iconHeight,
				style: {
					'float': 'right',
					marginTop: '-5px'
				},
				autoEl: {
					tag: 'img',
					src: config.icon
				}
			}, {
				xtype: 'component',
				style: {
					width: width * 0.6 +'px',
					wordWrap: 'break-word'
				},
				autoEl: {
					tag: 'h2',
					html: config.title
				}
			},{
				xtype: 'container',
				layout: 'column',
				defaults: {
					xtype: 'container',
					columnWidth: (1 / descriptionColumns) - (Ext.isIE8 || Ext.isIE9 ? 0.01 : 0),
					margin: 2,
					style: 'cursor:pointer; font-size: 8pt;'
				},
				style: {
					width: '266px',
					float: 'left',
					cursor: 'pointer'
				},
				items: items
			}]
		});
		
		me.callParent(arguments);
	},
	
	afterRender: function () {
		var me = this;
		if (me.handler && typeof(me.handler) == "function" )
			me.getEl().on('click', function () {
				me.handler(me);
			});
		
		me.callParent(arguments);
	}
});