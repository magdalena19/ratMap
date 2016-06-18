jQuery(function() {
  jQuery('#map').each(function() {
    jQuery(window).resize(function(){
      jQuery('#map').height(jQuery(window).height());
    }); // initial size is set in CSS, because curiously did not work properly here

    map = L.map('map', {
      zoomControl: false,
      minZoom: 5,
    });
    jQuery('.zoom-in').click(function() {map.zoomIn()});
    jQuery('.zoom-out').click(function() {map.zoomOut()});

    var addMap = function(url) {
      baselayer = L.tileLayer(url, {attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'});
      map.addLayer(baselayer);
      map.setView([52.513, 13.474], 12);
    };

     $.ajax({
        url: 'http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/1/1/1.jpg',
        success: function(result) {
          addMap('http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}.jpg');
        },     
        error: function(result) {
          addMap('http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png');
        }
     });

    var placeModal = jQuery('.place-modal');
    var onEachFeature = function(feature, layer) {
      layer._leaflet_id = feature.id; // for 'getLayer' function
      layer.on('click', function(e) {
        placeModal.find('.edit-place').attr('place_id', feature.properties.id);
        placeModal.find('.modal-title').html(feature.properties.name);
        placeModal.find('.place-description').html(feature.properties.description);
        placeModal.find('.place-address').html('<i>' + feature.properties.address + '</i>');
        placeModal.modal('show');
      });
    };

    var addPlaces = function(json) {
      marker = L.geoJson(json, {
        pointToLayer: function (feature, latlng) {
          return L.circleMarker(latlng, {color: 'black'});
        },
        onEachFeature: onEachFeature
      }).addTo(map);
    };
    addPlaces(window.placesJson);

    // CATEGORY AND PLACE BUTTONS
    jQuery('.zoom-to-place').click(function() {
      jQuery('.places-modal').modal('hide');
      clickedPlace = marker.getLayer(this.id);
      map.setView(clickedPlace.getLatLng(), 15, {animate: true});
    });

    jQuery('.show-places').click(function() {
      jQuery('.places-modal').modal('show');
    });

    jQuery('.show-categories').click(function() {
      jQuery('.category-modal').modal('show');
    });

    jQuery('.category-button').click( function() {
      jQuery('.category-modal').modal('hide');
      jQuery('.category-button').removeClass('active');
      jQuery(this).addClass('active');
      map.removeLayer(marker);
      var id = jQuery(this).attr('id');
      var category = jQuery(this).text();
      if (id == 'all') {
        addPlaces(window.placesJson);
        jQuery('.places-modal').find('.place-container').show();
      } else {
        var filteredPlaces = jQuery.grep(window.placesJson, function (feature){
          var categories = feature.properties.categories;
          return jQuery.inArray(parseInt(id), categories) > -1;
        });
        addPlaces(filteredPlaces);
        jQuery('.places-modal').find('.one-place').hide();
        jQuery('.places-modal').find('.' + id).show();
      };
      jQuery('.places-modal').find('.category').html(category);
      jQuery('.show-categories-text').html(category);
    });

    jQuery('.category-button#all').click();

    // ADD PLACE
    jQuery('.add-place-button').click(function(){
     jQuery('.add-place-modal').modal('show');
    });

    jQuery('.type-in-address').click(function(){
      window.location.href = 'places/new';
    });

    jQuery('.add-place-via-location').click(function(){
      function confirmation(position) {
        var longitude = position.coords.longitude;
        var latitude = position.coords.latitude;
        map.setView([latitude, longitude], 18);
        var myLocationMarker = L.circleMarker([latitude, longitude]).addTo(map);
        jQuery('.confirmation-button-container').show();
        jQuery('#confirmation-button-yes').click(function() {
          var params = 'longitude=' + longitude + '&' + 'latitude=' +  latitude;
          window.location.href = 'places/new?' + params;
        });
        jQuery('#confirmation-button-no').click(function() {
          window.location.href = 'places/new';
        });
      };

      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(confirmation);
      } else {
        console.log('Geolocation is not supported by this browser.');
      };
    });

    // ADMIN BUTTONS
    jQuery('.edit-place').click(function() {
      var placeId = jQuery(this).attr('place_id');
      window.location.href = 'places/' + placeId + '/edit';
    });

    // FRONTEND STUFF
    jQuery('.navbar-collapse')
      .on('show.bs.collapse', function() {
        jQuery('.zoom-container').animate({top:115}, 300);
      })
      .on('hide.bs.collapse', function() {
        jQuery('.zoom-container').animate({top:60}, 300);
      });

    var toggleTriangle = function(e) {
        jQuery(e.target)
            .prev('.panel-heading')
            .find('.triangle')
            .toggleClass('glyphicon-triangle-bottom glyphicon-triangle-top');
    }
    jQuery('#accordion')
      .on('hidden.bs.collapse', toggleTriangle)
      .on('shown.bs.collapse', toggleTriangle);
  });
});
