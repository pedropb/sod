Ext.define('Ext.ux.statusbar.StatusBar',{extend:'Ext.toolbar.Toolbar',alternateClassName:'Ext.ux.StatusBar',alias:'widget.statusbar',requires:['Ext.toolbar.TextItem'],cls:'x-statusbar',busyIconCls:'x-status-busy',busyText:'Loading...',autoClear:5000,emptyText:'&nbsp;',activeThreadId:0,initComponent:function(){if(this.statusAlign==='right'){this.cls+=' x-status-right';} this.callParent(arguments);},afterRender:function(){this.callParent(arguments);var right=this.statusAlign==='right';this.currIconCls=this.iconCls||this.defaultIconCls;this.statusEl=Ext.create('Ext.toolbar.TextItem',{cls:'x-status-text '+(this.currIconCls||''),text:this.text||this.defaultText||''});if(right){this.add('->');this.add(this.statusEl);}else{this.insert(0,this.statusEl);this.insert(1,'->');} this.height=27;this.doLayout();},setStatus:function(o){o=o||{};if(Ext.isString(o)){o={text:o};} if(o.text!==undefined){this.setText(o.text);} if(o.iconCls!==undefined){this.setIcon(o.iconCls);} if(o.clear){var c=o.clear,wait=this.autoClear,defaults={useDefaults:true,anim:true};if(Ext.isObject(c)){c=Ext.applyIf(c,defaults);if(c.wait){wait=c.wait;}}else if(Ext.isNumber(c)){wait=c;c=defaults;}else if(Ext.isBoolean(c)){c=defaults;} c.threadId=this.activeThreadId;Ext.defer(this.clearStatus,wait,this,[c]);} this.doLayout();return this;},clearStatus:function(o){o=o||{};if(o.threadId&&o.threadId!==this.activeThreadId){return this;} var text=o.useDefaults?this.defaultText:this.emptyText,iconCls=o.useDefaults?(this.defaultIconCls?this.defaultIconCls:''):'';if(o.anim){this.statusEl.el.puff({remove:false,useDisplay:true,scope:this,callback:function(){this.setStatus({text:text,iconCls:iconCls});this.statusEl.el.show();}});}else{this.statusEl.hide();this.setStatus({text:text,iconCls:iconCls});this.statusEl.show();} this.doLayout();return this;},setText:function(text){this.activeThreadId++;this.text=text||'';if(this.rendered){this.statusEl.setText(this.text);} return this;},getText:function(){return this.text;},setIcon:function(cls){this.activeThreadId++;cls=cls||'';if(this.rendered){if(this.currIconCls){this.statusEl.removeCls(this.currIconCls);this.currIconCls=null;} if(cls.length>0){this.statusEl.addCls(cls);this.currIconCls=cls;}}else{this.currIconCls=cls;} return this;},showBusy:function(o){if(Ext.isString(o)){o={text:o};} o=Ext.applyIf(o||{},{text:this.busyText,iconCls:this.busyIconCls});return this.setStatus(o);}});

/*
 * ExtJS User Extension - GTGrid
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('Ext.ux.GTGrid', {
    extend: 'Ext.grid.Panel',
    alias: ['widget.gtgrid'],
    
    completeLoad: true,
    minWidth: 220,
    
    searchable: true,
    exportable: true,
    
    viewConfig: {
    	loadingText: 'Carregando...'
    },
    
    // Highlight
	matchCls : 'x-livesearch-match',
	tagsRe : /<[^>]*>/gm,
	tagsProtect : '\x0f',
	
    initComponent: function() {
    	var me = this;

    	var tmpTBar = me.tbar;
    	var needsRightAlign = true;
    	for (var i in tmpTBar) {
    		if (tmpTBar[i] == '->') {
    			needsRightAlign = false;
    			break;
    		}
    	}
    	
    	var sep = false;
    	
    	me.tbar = [];
    	
    	// DOUBLE CLICK HANDLER
    	
    	if (typeof(me.dblClickHandler) == "function")
    		me.on('itemdblclick', me.dblClickHandler, me);
    	
    	
    	// TOOLBAR HANDLERS
    	
    	// local function used below
    	var createAddAction = function (handler, text, icon) {
    		if (!text)
    			text = 'Adicionar';
    			
    		if (!icon)
    			icon = 'gtgrid-icon-add';
    			
    		if (!handler) {
    			handler = function () {
    				console.log('Error: GTGrid.js -- createAddAction() handler is required and was not specified.');
    			};
    		}
    		
    		if (sep) {
    			me.tbar.push('-');
    			me.minWidth += 10;
    			sep=false;
    		}
    			
    		me.tbar.push({
	        	text: text,
                iconCls: icon,
	        	handler: handler
	        });
    		me.minWidth += 75;
    		
    		sep = true;
    	};
    	
    	// local function used below
    	var createEditAction = function (handler, text, icon) {
    		if (!text)
    			text = 'Editar';
    			
    		if (!icon)
    			icon = 'gtgrid-icon-edit';
    			
    		if (!handler) {
    			handler = function () {
    				var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione um registro.');
						return;
					}
					
        			me.editHandler(selection[0]);
    			};
    		}
    		
    		if (sep) {
    			me.tbar.push('-');
    			me.minWidth += 10;
    			sep=false;
    		}
    			
    		me.tbar.push({
	        	text: text,
                iconCls: icon,
	        	handler: handler
	        });
    		me.minWidth += 60;
    		
    		sep = true;
    		
    		if (!me.dblClickHandler)
    			me.on('itemdblclick', handler, me);
    	};
    	
    	// local function used below
    	var createRemoveAction = function (handler, text, icon) {
    		if (!text)
    			text = 'Remover';
    			
    		if (!icon)
    			icon = 'gtgrid-icon-delete';
    			
    		if (!handler) {
    			handler = function () {
    				var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione um registro.');
						return;
					}
					
        			me.removeHandler(selection[0]);
    			};
    		}
    		
    		if (sep) {
    			me.tbar.push('-');
    			me.minWidth += 10;
    			sep=false;
    		}
    		
    		me.tbar.push({
	        	text: text,
                iconCls: icon,
	        	handler: handler
	        });
    		me.minWidth += 75;
    		
    		sep = true;
    	};
    	
    	if (me.addWindow && typeof(me.addWindow) == "string") {
    		createAddAction(function () {
    			Ext.create(me.addWindow, {
    				store: me.store,
    				grid: me
    			}).show();
    		});
    	}
    	else if (typeof(me.addHandler) == "function") {
    		me.tbar.push({
				text: 'Adicionar',
                iconCls: 'gtgrid-icon-add',
				handler: me.addHandler
	        });
    		me.minWidth += 75;
    		
    		sep = true;
    	}
    	else if (me.addWindow && typeof(me.addWindow) == "object") {
    		// this should be used for GTPlanner's Add Windows that
    		// insert a register in the database before editing its
    		// data, i.e.: windows with an attachment grid inside it.
    		
    		/*
    		 * addWindow deve ser usado para criação de janelas Adicionar do GTPlanner
    		 * que criam um registro antes de mostrar a tela de adicionar. Por exemplo:
    		 * telas com grid de anexos.
    		 * 
    		 * Configuração:
    		 * addWindow: {
    		 * 		url: String - URL para o manager de criação do registro (deve aceitar uma action "add")
    		 * 		window: String - Nome da Classe ExtJS que define a Window de adição de registro 
    		 * 		actionParams: Object - JSON Object com os parâmetros que serão passados para o manager
    		 * 		windowParams: Object - JSON Object com os parâmetros que serão passados para a window 
    		 * }
    		 */
    		
    		if (typeof(me.addWindow) 		== "object" &&
    			typeof(me.addWindow.url) 	== "string" &&
    			typeof(me.addWindow.window) == "string")
    		{
    			createAddAction(function () {
        			Ext.Msg.wait('Adicionando...', 'Aguarde');
        			var params = {};
        			
        			if (typeof(me.addWindow.actionParams) == "object") {
						for (var key in me.addWindow.actionParams) {
							params[key] = me.addWindow.actionParams[key];
						}
					}
        			
        			params.action = 'add';
        			params.parentId = GTPlanner.app.activeTab._id;
        			
        			Ext.Ajax.request({
        				url: me.addWindow.url,
        				params: params,
        				success: function (response) {
        					var result = GeoTech.utils.prepareServerResponse(response);
    						
    						if (result != null && result.success == true && result.record != null) {
    							params = {};
    							
    							if (typeof(me.addWindow.windowParams) == "object") {
    								for (var key in me.addWindow.windowParams) {
    									params[key] = me.addWindow.windowParams[key];
    								}
    							}
    							
    							params.removeOnCancel = true;
    							params.store = me.store;    		        			
    		        			params.parentId = GTPlanner.app.activeTab._id;
    		        			params.record = Ext.create(me.store.model, result.record);
    							
    							Ext.Msg.hide();
    							Ext.create(me.addWindow.window, params).show();
    						}
    						else {
    							Ext.Msg.alert("Atenção!",	"<p>Falha ao criar registro no banco de dados.</p>"+
    														"<p>Verifique sua conexão com a Internet, recarregue a página e tente novamente.</p>"+
    														"<p>Se o erro persistir, entre em contato com o administrador do sistema.</p>");
    						}
        				},
        				failure: GeoTech.utils.prepareServerResponse
        			});
        		});
    		}
    		else {
    			console.log('Error: GTGrid.js -- expected "addWindow (Object)" with fields "url (String)", "window (String)" and "params (Object)".');
    		}
    	}
    	
    	if (me.editWindow && typeof(me.editWindow) == "string") {
    		me.editHandler = function (selection) {
    			Ext.create(me.editWindow, {
    				store: me.store,
    				record: selection,
    				grid: me
    			}).show();
    		};
    		
    		createEditAction();
    	}
    	else if (typeof(me.editHandler) == "function") {
    		createEditAction(me.editHandler);
    	}
    	else if (typeof(me.editWindow) 		== "object" &&
    			typeof(me.editWindow.window) == "string") {
    		
    		me.editHandler = function (selection) {
    			var params = {};
    			
    			if (typeof(me.editWindow.windowParams) == "object") {
    				for (var key in me.editWindow.windowParams) {
    					params[key] = me.editWindow.windowParams[key];
    				}
    			}
    			
    			Ext.create(me.editWindow.window, Ext.applyIf(params, {
    				store: me.store,
    				record: selection,
    				grid: me
    			})).show();
    		};
    		
    		createEditAction();
    	}

    	// default removeHandler in case config.removeHandler == true for Memory Stores
    	if (me.removeHandler) {
    		if (typeof(me.removeHandler) == "boolean") {
        		createRemoveAction(function () {
        			var selection = me.getSelectedRecords();
        			if (selection.length == 0) {
        				Ext.Msg.alert('Atenção!', 'Selecione um registro');
        				return;
        			}
        			Ext.Msg.confirm('Atenção!', 'Deseja realmente excluir?', function(answer) {
        				if (answer == 'yes') {
        					me.store.remove(selection);
        				}	
        			});
        		});
        	}
        	else if (typeof(me.removeHandler) == "function") {
        		createRemoveAction(me.removeHandler);
        	}
        	else if (typeof(me.removeHandler) == "string") {
        		/*
        		 * This can be used if you have a default manager for registers removal
        		 */
        		
        		createRemoveAction(function () {
        			
					var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione um registro.');
						return;
					}
					var record = selection[0];
					
					Ext.Msg.confirm('Atenção!', 'Deseja mesmo remover o registro selecionado?<br><b>Essa operação não pode ser desfeita.</b>', function (answer) {
						if (answer == 'yes') {
							Ext.Msg.wait('Removendo o registro...', 'Aguarde');
							Ext.Ajax.request({
								url: me.removeHandler,
								params: {
									action: 'remove',
									id: record.get('id')
								},
								success: function (response) {
									var result = GeoTech.utils.prepareServerResponse(response);
									
									if (result) {
										Ext.Msg.hide();
										GeoTech.utils.msg('Sucesso!', 'O registro foi removido com sucesso');
										me.getStore().load();
									}
								},
								failure: GeoTech.utils.prepareServerResponse
							});
						}
					});
        		});
        	}
        	else if (typeof(me.removeHandler) == "object" && typeof(me.removeHandler.url) == "string") {
        		/*
        		 * This config option can be used to setup a default manager for registers removal with some
        		 * custom parameters and messages.
        		 */
        		
        		createRemoveAction(function () {
        			
					var selection = me.getSelectedRecords();
					if (selection.length == 0) {
						Ext.Msg.alert('Atenção!', 'Selecione um registro.');
						return;
					}
					var record = selection[0];
					
					// override for confirmation message
					var confirmationMessage = 'Deseja mesmo remover o registro selecionado?<br><b>Essa operação não pode ser desfeita.</b>';
					if (typeof(me.removeHandler.confirmation) == "string") {
						confirmationMessage = me.removeHandler.confirmation;
					}
					
					// override for Ajax Parameters
					var params = {
						action: 'remove',
						id: record.get('id')
					};
					if (typeof(me.removeHandler.params) == "function") {
						params = Ext.apply(params, me.removeHandler.params(record));
					}
					else if (typeof(me.removeHandler.params) == "object"){
						params = Ext.apply(params, me.removeHandler.params);
					}
						
					// override for Success Function
					var successFn = function (response) {
						var result = GeoTech.utils.prepareServerResponse(response);
						
						if (result) {
							Ext.Msg.hide();
							GeoTech.utils.msg('Sucesso!', 'O registro foi removido com sucesso');
							me.getStore().load();
						}
					};
					if (typeof(me.removeHandler.success) == "function") {
						successFn = me.removeHandler.success;
					}
					
					// override for Failure Function
					var failureFn = GeoTech.utils.prepareServerResponse;
					if (typeof(me.removeHandler.failure) == "function") {
						failureFn = me.removeHandler.failure;
					}
					
					Ext.Msg.confirm('Atenção!', confirmationMessage, function (answer) {
						if (answer == 'yes') {
							// executing additional validations
							if (typeof(me.removeHandler.validation) == "function") {
								var validationResult = me.removeHandler.validation(record);
								if (validationResult !== true) {
									Ext.Msg.alert('Atenção!', validationResult);
									return;
								}
							}
							
							var removalFn = function () {
								Ext.Msg.wait('Removendo o registro...', 'Aguarde');
								Ext.Ajax.request({
									url: me.removeHandler.url,
									params: params,
									success: successFn,
									failure: failureFn
								});
							};
							
							if (me.removeHandler.checkConstraints === true) {
								Ext.Ajax.request({
									url: me.removeHandler.url,
									params: {
										action: 'checkConstraints',
										id: record.get('id')
									},
									success: function (response) {
										var result = GeoTech.utils.prepareServerResponse(response);
										if (!result)
											return;
										
										if (result.count == 0) {
											removalFn();
										}
										else {
											Ext.Msg.confirm('Atenção!', 'Existem <b>' + result.count + ' registros</b> associados ao registro selecionado. <b>Todos os ' + (result.count + 1) + ' registros serão removidos e não é possível reverter essa operação.</b><br><br>Deseja continuar?', function (answer) {
												if (answer == 'yes') {
													removalFn();
												}
											});
										}
									},
									failure: GeoTech.utils.prepareServerResponse
								});
							}
							else if (typeof(me.removeHandler.validationWithCallback) == "function") {
								me.removeHandler.validationWithCallback(record, removalFn);
							}
							else {
								removalFn();
							}
						}
					});
        		});
        	}
    	}
    	
    	if (tmpTBar)
    		me.tbar = me.tbar.concat(tmpTBar);   
    	
    	if (me.storeFilters)
    		console.log('Error: GTGrid.js --- storeFilters is deprecated, use tbarFilters instead.');
    		
    	if (me.tbarFilters instanceof Array) {
    		for (var i = 0; i < me.tbarFilters.length; i++) {
    			if (me.tbarFilters[i] == "-" || me.tbarFilters[i] == "|") {
    				me.tbar.push(me.tbarFilters[i]);
    				continue;
    			}
    			
    			if (me.tbarFilters[i] == "->") {
    				me.tbar.push("->");
    				needsRightAlign = false;
    				continue;
    			}
    			
    			if (typeof(me.tbarFilters[i].paramName) == "string")
    				me.tbar.push(me.tbarFilters[i]);
    			else
    				console.log("Error: GTGrid.js -- expected \"tbarFilters\" parameter with \"paramName\" attribute.");
    		}
    	}
    	
    	if (needsRightAlign) {
    		me.tbar.push('->');
    	}
    	sep = false;
    	
    	if (me.filters) {
    		var store = null;
    		if (typeof(me.store) == "string")
    			store = Ext.data.StoreManager.lookup(me.store);
    		else if (me.store instanceof Ext.data.Store)
    			store = me.store;
    		else
    			console.log('Error: GTGrid.js -- expected store config to be a string or an Ext.data.Store object');
    		
    		var filters = new Array();
    		for (var i = 0; i < me.filters.length;i ++)
    			filters.push(me.filters[i]);
    		
    		me.filterWindow = Ext.create('Ext.ux.GTFilterWindow', {
    			title: 'Filtros',
    			modal: true,
    			closable: true,
    			closeAction: 'hide',
    			store: store,
    			fields: filters
    		});
    		
    		me.tbar.push({
	        	text: 'Filtrar',
                iconCls: 'gtgrid-icon-filter',
	        	handler: function (btn) {
	        		var grid = btn.up('gtgrid');
	        		grid.filterWindow.show();
	        	}
	        });
    		
    		sep = true;
    	}
    	
    	if (sep) {
			me.tbar.push('-');
			sep = false;
		}
    	
    	if (me.searchable === true) {
    		me.tbar.push('Buscar', {
        		xtype : 'textfield',
        		itemId: 'searchField',
        		hideLabel : true,
        		enableKeyEvents : true,
        		width : 150,
        		listeners: {
        			'keydown': me.textFieldKeyDownListener
        		}
        	});
        }
    	
    	var bbarItems = ['->'];
    	
    	if (me.bbar)
    		bbarItems = bbarItems.concat(me.bbar);
    	
    	if (me.exportable === true) {
    		if (typeof(me.title) != "string") {
    			console.log('Warning: GTGrid.js -- exportable requires title in order to work correctly. Default title was set.');
    			me.title = "grid";
    			me.preventHeader = true;
    		}
    		
    		bbarItems.push({
		    	text: 'Exportar...',
                iconCls: 'gtgrid-icon-xls',
		    	handler: function (btn) {
		    		var grid = btn.up('gtgrid');
		    		
		    		Ext.create('Ext.window.Window', {
		    			modal: true,
		    			title: 'Escolha o formato',
		    			width: 300,
		    			height: 150,
		    			
		    			layout: 'fit',
		    			
		    			items: [{
							xtype: 'form',
					    	border: false,
					    	frame: true,
					    	bodyPadding: 10,
					    	layout: 'fit',
					    	autoScroll: false,
					    	items: [{
					    		xtype: 'radiogroup',
					    		fieldLabel: 'Formato',
					    		labelAling: 'top',
					    		defaults: {
					    			name: 'format'
					    		},
					    		vertical: true,
					    		columns: 1,
					    		items: [{
					    			boxLabel: 'XLS (Excel 97-2003)',
					    			inputValue: 'XLS'
					    		},{
					    			boxLabel: 'XLSX (Excel 2007-*)',
					    			inputValue: 'XLSX',
					    			checked: true
					    		}]
					    	}]
					    }],
					    
					    buttons: [{
					    	text: 'Exportar',
					    	handler: function (btn) {
					    		var win = btn.up('window');
					    		
					    		var columns = [];
					    		for (var j in grid.columns) {
					    			if (!grid.columns[j].hidden || grid.columns[j].dataIndex == grid.store.groupField) {
					    				var column = {
					    					title: grid.columns[j].text,
					    					index: grid.columns[j].dataIndex,
					    					type: grid.columns[j].xtype
					    				};
					    				
					    				columns.push(column);
					    			}
					    		}
					    		
					    		var storeParams = '';
					    		try {
					    			var lastOptions = grid.getStore().lastOptions;
					    			if (lastOptions) {
					    				storeParams = Ext.apply(Ext.clone(grid.getStore().getProxy().extraParams), lastOptions.params);
					    			}
					    			else {
					    				storeParams = grid.getStore().getProxy().extraParams;
					    			}
					    			
						    		storeParams = Ext.encode({
						    			url: grid.getStore().getProxy().url,
						    			params: storeParams
						    		});
						    		
						    		var form = win.down("form").getForm();
						    		
						    		GeoTech.utils.formSubmit({
										url: grid.xlsExportAction,
										params: {
											title: grid.title,
											columns: Ext.encode(columns),
											storeParams: storeParams,
											format: form.findField("format").getSubmitValue()
										}
									});
					    		} catch (ex) {
					    			console.log('Não foi possível exportar os dados.');
					    		}
					    		
					    		
					    		win.close();
					    	}
					    },{
					    	text: 'Cancelar',
					    	handler: function (btn) {
					    		var win = btn.up('window');
					    		
					    		win.close();
					    	}
					    }]
		    		
		    		
		    		}).show();
		    	}
		    });
    	}
    	
    	if (me.searchable === true || me.exportable === true) {
    		me.bbar = Ext.create('Ext.ux.StatusBar', {
        		defaultText : (me.searchable === true ? me.defaultStatusText : ''),
        		itemId : 'searchStatusBar',
        		items: bbarItems
        	});
    	}
    	
    	
    	if (me.tbar.length == 0 || (me.tbar.length == 1 && me.tbar[0] == '->'))
    		delete me.tbar;
    		
		if (me.visibleColumns instanceof Array) {
			for (var i = 0; i < me.columns.length; i++) {
				me.columns[i].hidden = me.visibleColumns.indexOf(me.columns[i].text) == -1;
			}
		}
		
    	
    	me.callParent(arguments);
    },
    
    updateRecordCount: function () {
    	var me = this;

    	var store = me.getStore();
    	var totalCount = store.buffered ? store.getTotalCount() : store.getCount();
    	
    	if (!me.statusBar)
    		me.statusBar = me.down('statusbar[itemId=searchStatusBar]');
    	
		me.statusBar.setStatus({
            text: totalCount + ' registro'+(totalCount > 1 || totalCount == 0 ? 's.' : '.'),
            iconCls: ''
        });
    },
    
    afterRender: function() {
        var me = this;
        me.callParent(arguments);
        
        if (me.searchable === true) {
            var store = me.getStore();
        	store.on('refresh', me.updateRecordCount, me);
        	store.on('datachanged', me.updateRecordCount, me);
        }
    	
    	// handling tbarFilters
    	if (me.tbarFilters instanceof Array) {
    		var tbar = me.getDockedItems('toolbar')[0];
        	for (var i = 0; i < tbar.items.items.length; i++) {
        		var item = tbar.items.items[i];
        		
        		if (typeof(item.paramName) == "string") {
        			item.on('change', function (comp) {
        				me.updateTbarFilters();
        			});
        		} 
        	}
    	}
    },
    
    updateTbarFilters: function () {
    	var me = this;
    	
    	var tbar = me.getDockedItems('toolbar')[0];
    	var store = me.getStore();
    	var proxy = store.getProxy();
    	
    	if (!proxy.extraParams)
    		proxy.extraParams = {};
    	
    	var incomplete = false;
    	
    	for (var i = 0; i < tbar.items.items.length; i++) {
			var field = tbar.items.items[i];
			
			if (field.paramName != null) {
				if (field.isValid()) {
					proxy.extraParams[field.paramName] = field.getSubmitValue();
				}
				else {
					incomplete = true;
					break;
				}
			}
    	}
    	
    	if (!incomplete || !me.completeLoad) {
			store.abort().loadData([], false);
			store.load();
    	}
    },
    
    textFieldKeyDownListener: function (field, ev) {
    	var me = field.ownerCt.ownerCt;
    	var key = ev.getKey();
    	if (key == ev.ENTER) {
    		// load store filter
    		var filters = [];
    		var store = me.getStore();
    		var value = field.getValue();
    		
    		for (var j in me.columns) {
    			var dataIndex = me.columns[j].dataIndex;
    			var type = "";
    			
    			switch (me.columns[j].xtype) {
    				case "datecolumn":
    					type = "-date";
    					break;
    				default:
    					type = "";
    					break;
    			}
    			
    			if (!me.columns[j].hidden || dataIndex == store.groupField) {
    				filters.push({
    					id: 'search-' + dataIndex,
    					property: dataIndex + type,
    					value:  value
    				});
    			}
    			else {
    				filters.push({
    					id: 'search-' + dataIndex,
    					property: dataIndex + type,
    					value:  ''
    				});
				}
    		}
    		
    		store.on({
    			refresh: me.highlightRecords,
    			scope: me,
    			single: true
    		});
    		
    		var searchValue = me.down('textfield[itemId=searchField]').getValue();
    		var searchRegExp = new RegExp(searchValue, 'gi');
    		
    		if (!searchValue || searchValue.length == 0) {
    			me.getView().getEl().un('DOMNodeInserted', me.highlightHandler);
    		}
    		else {
    			me.getView().getEl().un('DOMNodeInserted', me.highlightHandler);
    			
    			me.highlightHandler = function (e, t) {
    				if (t.tagName == "TR") {
    					t = Ext.get(t);
    					
    					var cell,
        				matches,
        				cellHTML,
        				innerText;

        				var td = t.down('td');
    					
    					while (td) {
    						cell = td.down('.x-grid-cell-inner');
    						innerText = cell.dom.innerText || cell.dom.textContent;
    						matches = innerText.match(me.tagsRe);
    						cellHTML = innerText.replace(me.tagsRe, me.tagsProtect);
    						cellHTML = cellHTML.replace(searchRegExp, function (m) {
    							return '<span class="' + me.matchCls + '">' + m + '</span>';
    						});
    						Ext.each(matches, function (match) {
    							cellHTML = cellHTML.replace(me.tagsProtect, match);
    						});
    						cell.dom.innerHTML = cellHTML;
    						td = td.next();
    					}
    				}
    			};
    			
    			me.getView().getEl().on('DOMNodeInserted', me.highlightHandler);
    		}
    		
    		store.filter(filters);
    	}    	
    },
    
    highlightRecords: function () {
    	var me = this;
    	
    	if (!me.textField)
    		me.textField = me.down('textfield[itemId=searchField]');
    	
    	var searchValue = me.textField.getValue();
		var indexes = [];
		var currentIndex = null;
		if (searchValue !== null && searchValue.length > 0) {
			var searchRegExp = new RegExp(searchValue, 'gi');
			var store = me.getStore();
			
			store.each(function (record, idx) {
				var tr = Ext.fly(me.view.getNode(idx)),
				cell,
				matches,
				cellHTML,
				innerText;
				while (tr) {
					var td = tr.down('td');
					
					while (td) {
						cell = td.down('.x-grid-cell-inner');
						innerText = cell.dom.innerText || cell.dom.textContent;
						matches = innerText.match(me.tagsRe);
						cellHTML = innerText.replace(me.tagsRe, me.tagsProtect);
						cellHTML = cellHTML.replace(searchRegExp, function (m) {
								if (Ext.Array.indexOf(indexes, idx) === -1) {
									indexes.push(idx);
								}
								if (currentIndex === null) {
									currentIndex = idx;
								}
								return '<span class="' + me.matchCls + '">' + m + '</span>';
							});
						Ext.each(matches, function (match) {
							cellHTML = cellHTML.replace(me.tagsProtect, match);
						});
						cell.dom.innerHTML = cellHTML;
						td = td.next();
					}
					tr = tr.next();
				}
			}, me);
		}
    },
    
    getSelectedRecords: function () {
    	var me = this;
    	
    	return me.getSelectionModel().getSelection();
    }
});
