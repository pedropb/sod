__mapCounter = 0;

Ext.define('Ext.ux.Map', {
	extend: 'Ext.container.Container',
	alias: ['widget.map'],
		
	_lat: -19.9190677, 
	_lon: -43.938574700000004,
	
	constructor: function(config) {
		var me = this;
		
		me.mapId = 'mapId-' + ++__mapCounter;
		me.latId = me.mapId + '.lat';
		me.lonId = me.mapId + '.lon';
		
		me.mapWidth = (config.mapWidth ? config.mapWidth : '600px');
		me.mapHeight = (config.mapHeight ? config.mapHeight : '400px');
		
		if (typeof(me.mapWidth) == "number")
			me.mapWidth = me.mapWidth + 'px';
			
		if (typeof(me.mapHeight) == "number")
			me.mapHeight = me.mapHeight + 'px';
	   
		me.zoom = (config.zoom ? config.zoom : 6);
		
		me.showCoords = (config.showCoords !== null ? config.showCoords : true);
		me.coordsPrecision = (config.coordsPrecision ? config.coordsPrecision : 5);
		
		me.initConfig(config);
		
		Ext.apply(me, {
			html: (me.showCoords ? '<table bgcolor="#FFFFCC" width="300">'+
								   '<tbody><tr>'+
								   '<td><b>Latitude</b></td>'+
								   '<td><b>Longitude</b></td>'+
								   '</tr>'+
								   '<tr>'+
								   '<td id="'+me.latId+'">' + config.lat + '</td>'+
								   '<td id="'+me.lonId+'">' + config.lon + '</td>'+
								   '</tr>'+
								   '</tbody></table>' :  '') +
								   '<div align="center" id="'+me.mapId+'" style="width: '+me.mapWidth+'; height: '+me.mapHeight+'"></div>'});
		me.callParent(arguments);
	},
	
	afterRender: function () {
		var me = this;
		
		var initialize = function () {
			var center = new google.maps.LatLng(me.lat, me.lon);
			
			var options = {
				center: center,
				zoom: 15,
				mapTypeId: google.maps.MapTypeId.ROADMAP
			};
		
			me.map = new google.maps.Map(document.getElementById(me.mapId), options);
			
			me.marker = new google.maps.Marker({
				position: center,
				draggable : false
			});
			me.marker.setMap(me.map);
					
			if (me.clickable) {
				me.marker.setDraggable(true);
				
				google.maps.event.addListener(me.map, "click", function(event) {
					var lat = event.latLng.lat();
					var lon = event.latLng.lng();
			
					var point = new google.maps.LatLng(lat, lon);
					me.marker.setPosition(point);
								
					me.updateCoords(center);
				});
			}
			else if (me.draggable) {
				me.marker.setDraggable(true);
				
				google.maps.event.addListener(me.marker, "dragend", function() {
					var point = me.marker.getPosition();
					me.map.panTo(point);
				});
				
				google.maps.event.addListener(me.map, "dragend", function() {
					var center = me.map.getCenter();
					me.marker.setPosition(center);
					me.updateCoords(center);
				});
				
				google.maps.event.addListener(me.map, "zoom_changed", function() {
					var center = me.map.getCenter();
					me.marker.setPosition(center);
					me.updateCoords(center);
				});
			}			
		};		
		
		if (me.lat && me.lon) {
			initialize();
		}
		else if (me.address) {
			new google.maps.Geocoder().geocode({
				address: me.address
			}, function(results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					me.lat = results[0].geometry.location.lat();
					me.lon = results[0].geometry.location.lng();
					
					initialize();
				} else {
					console.log("Geocode was not successful for the following reason: " + status);
					
					me.lat = me._lat; 
					me.lon = me._lon;
					
					initialize();
				}
			});
		}
		else {
			me.lat = me._lat; 
			me.lon = me._lon;
			
			initialize();
		}
	},
	
	updateCoords: function (point) {
		var me = this;
		
		if (me.latEl)
			this.latEl.innerHTML = point.lat().toFixed(me.coordsPrecision);
			
		if (me.lonEl)
			me.lonEl.innerHTML = point.lng().toFixed(me.coordsPrecision);
			
		me.fireEvent('change', me);
		return me;
	},
	
	getLat: function () {
		return this.getLatLon().lat;
	},
	
	getLon: function () {
		return this.getLatLon().lon;
	},
	
	getLatLon: function () {
		return {
			lat: this.map.getCenter().lat().toFixed(this.coordsPrecision),
			lon: this.map.getCenter().lng().toFixed(this.coordsPrecision)
		};
	},
	
	setCenter: function (lat, lon) {
		var me = this;
		
		if (lat && lon) {
			me.lat = lat;
			me.lon = lon;
		}
		
		var center = new google.maps.LatLng(me.lat, me.lon);
		me.map.panTo(center);
		
		me.updateCoords(center);
		
		return me;
	}
});