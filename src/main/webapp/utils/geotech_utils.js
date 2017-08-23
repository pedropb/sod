Ext.namespace('GeoTech.utils');

GeoTech.utils = function() {

	var delayMS = 3000;
	var lastMsgTime = (new Date()).getTime();
	var m = null;
	
	var LOCALE = "pt_br";
	
	var DATE_LOCALE = {
		pt_br: {
			month: ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'],
			monthAbbrev: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
			weekday: ['Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'],
			weekdayAbbrev: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
		},
		en_us: {
			month: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
			monthAbbrev: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
			weekday: ['Sunday', 'Monday', 'Tueday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
			weekdayAbbrev: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
		}
	};
	
	var MONEY_RENDERERS = {
		fn: function (value, currency, thousandSeparator, decimalSeparator, decimalPrecision) {
			if (!thousandSeparator || typeof(thousandSeparator) != 'string')
				thousandSeparator = '';
			if (!decimalSeparator || typeof(decimalSeparator) != 'string')
				decimalSeparator = '.';
			if (!decimalPrecision || typeof(decimalPrecision) != 'number')
				decimalPrecision = 2;
			
			var neg = null;
			
			var v = value;
			v = (neg = v < 0) ? v * -1 : v;	
			v = v.toFixed(decimalPrecision);
			
			v = String(v);
	
			var ps = v.split('.');
            ps[1] = ps[1] ? ps[1] : null;
            
            var whole = ps[0];
            
            var r = /(\d+)(\d{3})/;

			var ts = thousandSeparator;
			
            while (r.test(whole)) 
                whole = whole.replace(r, '$1' + ts + '$2');
        
		    v = whole + (ps[1] ? decimalSeparator + ps[1] : '');
			
			return (neg ? '-' : '') + (currency ?  currency + ' ' : '') + v;
		},
			
		pt_br: function (value) {
			return this.fn(value, 'R$', '.', ',', 2);
		},
		
		en_us: function (value) {
			return this.fn(value, 'US$', ',', '.', 2);
		}
	};
	
	function createBox(t, s) {
       return '<div class="msg"><h3>' + t + '</h3><p>' + s + '</p></div>';
    };
    
    return {
        showMessage: function(title, text, node){
        	if (node == null)
				node=document.getElementById('msg-ct');
        	
        	currentTime = (new Date()).getTime();
        	if ( currentTime - lastMsgTime < delayMS) {
        		if (m != null)
        			m.hide();
        	}
        	
    		m = Ext.core.DomHelper.insertAfter(node, createBox(title, text), true);
            m.hide();
            m.slideIn('t').ghost("t", { delay: delayMS, remove: true});
            lastMsgTime = currentTime;
        },
        
        msg: function(title, text, node){
        	GeoTech.utils.showMessage(title, text, node);
        },
    
        /*
         * Format Options:
         * 		"da" - Day in week abbreviated (i.e: Fri)
         * 		"DA" - Day in week (i.e: Friday)
         * 		"dd" - Day in month 2-digit (i.e: 27)
         * 		"mo" - Month literal abbreviated (i.e: Jan)
         * 		"MO" - Month literal (i.e: January)
         * 		"mm" - Month in year 2-digit (i.e: 01)
         * 		"yyyy" - Year 4-digit (i.e: 2012)
         * 		"t" - Full time (i.e: 14:00:57)
         * 		"ho" - Hour 00 to 24  (i.e: 14)
         * 		"mi" - Minutes 00 to 60 (i.e: 00)
         * 		"s" - Seconds 00 to 60 (i.e: 57)
         * 		"g" - GMT Zone (i.e: -0200)
         */
    	formatDate: function (format, date) {
    		if (!date)
    			date = new Date();
    		else if (typeof (date) == 'string')
    			date = new Date(date);
    		else if (!(typeof(date) == 'object' && date instanceof Date)) {
    			console.log("GeoTech.utils.formatDate: erro ao formatar data (" + date + ")");
    			return "";
    		}
    		
    		var gmt = date.getTimezoneOffset();
    		var gmtMinutes = Math.abs(gmt % 60);
    		var gmtHours = Math.floor(gmt / 60);
    		
    		// "Fri Jan 27 2012 14:00:57 GMT-0200 (E. South America Daylight Time)"
    		var dateObject = {
    			weekday: date.getUTCDay(),
    			month: date.getUTCMonth(),
    			day: date.getUTCDate(),
    			year: date.getUTCFullYear(),
    			time: date.getUTCHours() + ':'+ date.getUTCMinutes()+ ':'+ date.getUTCSeconds(),
    			hour: date.getUTCHours(),
    			minute: date.getUTCMinutes(),
    			second: date.getUTCSeconds(),
    			gmt: gmtHours + "" + gmtMinutes    			
    		};
    		
    		var userLocale = DATE_LOCALE[LOCALE];
    		
    		var result = '';
    		while (format.length > 0) {

        		// "da" - Day in week abbreviated (i.e: Fri)
    			if (format.indexOf("da") == 0) {
    				result += userLocale.weekdayAbbrev[dateObject.weekday];
    				format = format.substring(2);
    			}
    			
    			// "DA" - Day in week (i.e: Friday)
    			else if (format.indexOf("DA") == 0) {
    				result += userLocale.weekday[dateObject.weekday];
    				format = format.substring(2);
    			}
    			
    			// "dd" - Day in month 2-digit (i.e: 27)
    			else if (format.indexOf("dd") == 0) {
    				var d = dateObject.day;
    				result += (d < 10 ? '0'+d : d.toString());
    				format = format.substring(2);
    			}
    			
    			// "mo" - Month literal abbreviated (i.e: Jan)
    			else if (format.indexOf("mo") == 0) {
    				result += userLocale.monthAbbrev[dateObject.month];
    				format = format.substring(2);
    			}
    			
    			// "MO" - Month literal (i.e: January)
    			else if (format.indexOf("MO") == 0) {
    				result += userLocale.month[dateObject.month];
    				format = format.substring(2);
    			}
    			
    			// "mm" - Month in year 2-digit (i.e: 01)
    			else if (format.indexOf("mm") == 0) {
    				var m = dateObject.month + 1;
    				result += (m < 10 ? '0'+m : m.toString());
    				format = format.substring(2);
    			}
    			
    			// "yyyy" - Year 4-digit (i.e: 2012)
    			else if (format.indexOf("yyyy") == 0) {
    				result += dateObject.year;
    				format = format.substring(4);
    			}
    			
    			// "t" - Full time (i.e: 14:00:57)
    			else if (format.indexOf("t") == 0) {
    				t = dateObject.time.split(":");
    				
    				result += (t[0].length < 2? '0'+t[0]+':':t[0]+':');
    				result += (t[1].length < 2? '0'+t[1]+':':t[1]+':');
    				result += (t[2].length < 2? '0'+t[2] : t[2]);
    				format = format.substring(1);
    			}
    			
    			// "ho" - Hour 00 to 24  (i.e: 14)
    			else if (format.indexOf("ho") == 0) {
    				if (dateObject.hour < 10)
    					result += '0';
    				result += dateObject.hour;
    				format = format.substring(2);
    			}
    			
    			// "mi" - Minutes 00 to 60 (i.e: 00)
    			else if (format.indexOf("mi") == 0) {
    				if (dateObject.minute < 10)
    					result += '0';
    				result += dateObject.minute;
    				format = format.substring(2);
    			}
    			
    			// "s" - Seconds 00 to 60 (i.e: 57)
    			else if (format.indexOf("s") == 0) {
    				if (dateObject.second < 10)
    					result += '0';
    				result += dateObject.second;
    				format = format.substring(1);
    			}
    			
    			// "g" - GMT Zone (i.e: -0200)
    			else if (format.indexOf("g") == 0) {
    				result += dateObject.gmt;
    				format = format.substring(1);
    			}
    			
    			else {
    				result += format[0];
    				format = format.substring(1);
    			}
    		}
    		
    		return result;
    	},
    	
    	
    	/*
    	 * XML Handling Functions
    	 */
    	
    	getNodeValue: function (node) {
    		return unescape(node.textContent ? node.textContent.trim() : node.text.trim());
    	},

    	getNodeValueFromTag: function (xmlDoc, tagName) {
    		var node = null;
    		
    		if ((xmlDoc == null) ||
	    		(xmlDoc.getElementsByTagName(tagName) == null) ||
	    		(xmlDoc.getElementsByTagName(tagName).item(0) == null) ||
	    		(xmlDoc.getElementsByTagName(tagName).item(0).firstChild == null))
	    		return "";
    		else
    			node = xmlDoc.getElementsByTagName(tagName).item(0).firstChild;
    		
	    	var value;
	    	if(Ext.isIE)
	    		value = unescape(node.nodeValue);
	    	else
	    		value = unescape(node.wholeText);
	    	
	    	if(value == null || value == 'null')
	    		return "";
	    	else
	    		return unescape(value).trim();
    	},

    	getChildNodesFromTag: function (xmlDoc, tagName) {
    		if ((xmlDoc.getElementsByTagName(tagName) == null) ||
	    		(xmlDoc.getElementsByTagName(tagName).item(0) == null) ||
	    		(xmlDoc.getElementsByTagName(tagName).item(0).firstChild == null))
	    		return [];
	    	
	    	var value = xmlDoc.getElementsByTagName(tagName)[0].childNodes;
	    	if(value == null)
	    		return [];
	    	else
	    		return value;
    	},
    	
    	
    	/*
    	 * Navigate on card tabs function
    	 */
    	cardAbsNav: function(index, cardId, size, title, titleCmp){
    	    var l = Ext.getCmp(cardId).getLayout();
    	    l.setActiveItem(index);
    	    
    	    if (titleCmp)
    	    	Ext.getCmp(titleCmp).setTitle(title);
    		
    	    for (var i = 0; i < size; i++)
    	    {
    	    	Ext.getCmp(cardId + '-nav-' + i).setDisabled(i == index);
    	    }
    	},
    	
    	/*
    	 * Usage example:
    	 * 		{
	     *			xtype: 'templatecolumn',
	     *			text: 'Última compra',
	     *			renderer: GeoTech.utils.renderers.money
	     *		}
    	 */
    	renderers: {
    		money: function (value) {
    			var v = parseFloat(value);
    			if (isNaN(v))
    				return '';
    			else
    				return MONEY_RENDERERS[LOCALE](v);
    		},
    		
    		boldmoney: function (value) {
    			var v = parseFloat(value);
    			if (isNaN(v))
    				return '';
    			else
    				return '<b>' + MONEY_RENDERERS[LOCALE](v) + '</b>';
    		},
    		
    		coloredmoney: function (value) {
    			var v = parseFloat(value);
    			if (isNaN(v))
    				return '';
    			else {
    				var color = (v > 0 ? 'green' : 'red');
    				return '<span style="color: '+color+'">' + MONEY_RENDERERS[LOCALE](v) + '</span>';
    			}
    		},
    		
    		absolutemoney: function (value) {
    			var v = parseFloat(value);
    			if (isNaN(v))
    				return '';
    			else {
    				if (v < 0)
    					v = -v;
    				
    				return MONEY_RENDERERS[LOCALE](v);
    			}
    		},
    		
    		month: function (value) {
    			if (typeof(value) != "number")
    				return "";
    			
    			var d = new Date();
    			d.setMonth(Math.round(value));
    			return GeoTech.utils.formatDate('MO', d);
    		},
    		
    		percent: function (value) {
    			if (typeof(value) != "number")
    				return "";
    			
    			return (100 * value).toFixed(2) + '%';
    		}
    	},
    	
		getMonthStore: function () {
			var data = new Array;
			
			var months = DATE_LOCALE[LOCALE].month;
			
			for (var i=0; i < months.length; i++) {
				data.push({
					text: months[i],
					number: i+1
				});
			}
			
			return Ext.create('Ext.data.Store', {
				autoLoad: true,
				fields: ['text', 'number'],
				data: data
			});
		},
		
		formSubmit: function (config) {
			if (!config) {
				console.log('GeoTech.utils.formSubmit error: The config parameter is required');
				return;
			}
			
			if (!config.url){
				console.log('GeoTech.utils.formSubmit error: The config.url parameter is required');
				return;
			}
			
    		var form = document.createElement('form');
    		form.method = config.method || 'post';
    		form.target = config.target || '_self';
    		form.action = config.url;

    		for (var param in config.params) {
    			var input = document.createElement('input');
    			input.setAttribute('name', param);
    			input.setAttribute('value', config.params[param]);
    			form.appendChild(input);
    		}
    			
    		document.body.appendChild(form);
    		form.submit();
    		document.body.removeChild(form);
		},
		
		/*
		 * This method parses a JSON server response and prints errors if they are found.
		 * Otherwise, it just returns the parsed response.
		 * 
		 * This method should ALWAYS be used inside Ajax.request() success and failure functions.
		 */
		prepareServerResponse: function (response) {
			var result = null;
			try {
				result = Ext.decode(response.responseText);
			}
			catch (ex) {
				result = null;
			}
			
			if (result != null && typeof(result) == "object" && result.success == true) {
				return result;
			}
			else {
				if (result != null && typeof(result.message) == "string")
					Ext.Msg.alert('Atenção!', result.message);
				else
					GeoTech.utils.showErrorMessage();
				
				return null;
			}
		},
		
		/*
		 * This method prints an error message with context information for the end user.
		 * It also provides a basic feedback channel via <a href="mailto:">
		 * 
		 * If no context is passed, it prints a default error message.
		 */
		showErrorMessage: function (context) {
			if (!context) {
				if (GTPlanner)
					context = GTPlanner;
				else
					context = {};
			}
			
			var title = typeof(context.title) == "string" ? context.title : "Atenção!";
			var errorMessage = typeof(context.errorMessage) == "string" ? context.errorMessage : "Ocorreram erros durante a realização da operação.";
			var recoverMessage = typeof(context.recoverMessage) == "string" ? context.recoverMessage : "Por favor, verifique suas conexões de rede, recarregue a página e tente novamente.";
			
			var appName = (typeof(context.appName) == "string" ? "[" + context.appName + "] " : "");
			
			var appResponsible,
				appSupportMail;
			
			if (context && typeof(context.appResponsible) == "string" && typeof(context.appSupportMail) == "string") {
				appResponsible = context.appResponsible;
				appSupportMail = context.appSupportMail;
			}
			else {
				appResponsible = "Pedro Baracho";
				appSupportMail = "pedropbaracho@gmail.com";
			}
			
			var action = (context && typeof(context.action) == "string" ? context.action : "");
			
			var emailSubject = appName + "Relato de Erro: " + action;
			var emailBody = "[[Descreva os passos que você executou até a ocorrência do erro e o que era esperado]]";
			
			var contactInfo = "Se o erro persistir, entre em contato com: <a target='_blank' href='mailto:"+appSupportMail+"?subject="+emailSubject+"&body="+emailBody+"'>"+ appResponsible +".</a>";
			
			Ext.Msg.alert(title, '<p>'+errorMessage+'</p><p>'+recoverMessage+'</p><p>'+contactInfo+'</p>');
		},

		getLatLonFromAddress: function (address, callback, caller) {
        	if (typeof(GBrowserIsCompatible) == "function" && GBrowserIsCompatible()) {
        		
        		var geocoder = new GClientGeocoder();
            	if (geocoder) {
        			geocoder.getLatLng(address, function(point) {
        				if (!point) {
        					//Ext.Msg.alert("Erro", "Endereço não encontrado: "+address);
        				}
        				else {
        					callback.call(caller, point);
        				}
        			});
            	}
        	}
        },
        
        removeHtmlTags: function (value) {
			return value.replace(/(<([^>]+)>)/ig," ").replace(/\s+/g, " ").trim();
		},
		
		getScreenHeight: function () {
			if (self.innerHeight) { // all except Explorer
				return self.innerHeight;
			}
			else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
				return document.documentElement.clientHeight;
			}
			else if (document.body) { // other Explorers
				return document.body.clientHeight;
			}
		}
    };
}();

function pegaValor(el)
{
	return unescape(el.textContent ? el.textContent.trim() : el.text.trim());
}

function pegaConteudoTagXML(xml, nomeTag)
{
	if ((xml == null) ||
		(xml.getElementsByTagName(nomeTag) == null) ||
		(xml.getElementsByTagName(nomeTag).item(0) == null) ||
		(xml.getElementsByTagName(nomeTag).item(0).firstChild == null))
		return "";
	
	var valor = xml.getElementsByTagName(nomeTag).item(0).firstChild.nodeValue;
	if(valor == null || valor == 'null')
		return "";
	else
		return unescape(valor).trim();
}

function pegaConteudoLongoTagXML(xml, nomeTag)
{
	if ((xml.getElementsByTagName(nomeTag) == null) ||
		(xml.getElementsByTagName(nomeTag).item(0) == null) ||
		(xml.getElementsByTagName(nomeTag).item(0).firstChild == null))
		return "";
	
	var valor = "";
	if(Ext.isIE)
		valor = unescape(xml.getElementsByTagName(nomeTag).item(0).firstChild.nodeValue);
	else
		valor = unescape(xml.getElementsByTagName(nomeTag).item(0).firstChild.wholeText);
		
	if(valor == null || valor == 'null')
		return "";
	else
		return unescape(valor).trim();
}

function pegaChildNodesTagXML(xml, nomeTag)
{
	if ((xml.getElementsByTagName(nomeTag) == null) ||
		(xml.getElementsByTagName(nomeTag).item(0) == null) ||
		(xml.getElementsByTagName(nomeTag).item(0).firstChild == null))
		return [];
	
	var valor = xml.getElementsByTagName(nomeTag)[0].childNodes;
	if(valor == null)
		return [];
	else
		return valor;
}