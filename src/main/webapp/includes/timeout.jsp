	setInterval(function() {
		Ext.Ajax.request({
			url: 'actions/keepMeAlive.jsp',
			success: function () {
			},
			failure: function () {
				Ext.MessageBox.alert("Aten��o", "A conex�o com o servidor foi interrompida!",
						function () {
							Ext.Ajax.request ({
								 url: 'actions/login.jsp',
									params: {
										action: 'logout'
									},
									success: function() {
										window.location.assign("index.jsp");
									},
									failure: function() {
										Ext.MessageBox.alert("Erro", "Aconteceu um erro durante a sa�da. Se o erro persistir, contate a administradora do sistema.");
										window.location.assign("index.jsp");
									}
							 });
				});
			}
		});
	}, 300000);