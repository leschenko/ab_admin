class window.GeoInput
  constructor: (@dom_lat, @dom_lon, @dom_zoom, @options={}) ->
    defaults =
      lat: 55.7427928
      lon: 37.61540089999994
      zoom: 12
      doom_map: 'admin_map'
      types: ['geocode']
      map_options: {}
    _.defaults(@options, defaults)
    @callback = window[@options.callback] if _.isFunction(window[@options.callback])
    @marker_callback = window[@options.marker_callback] if _.isFunction(window[@options.marker_callback])
    @lat_el = $('#' + @dom_lat)
    @lon_el = $('#' + @dom_lon);
    @zoom_el = $('#' + @dom_zoom);

    @lat = parseFloat(@lat_el.val()) or @options.lat
    @lon = parseFloat(@lon_el.val()) or @options.lon
    @zoom = parseInt(@zoom_el.val(), 10) or @options.zoom
    @lat_lon = new google.maps.LatLng(@lat, @lon)
    @initGMap()
    @initMarker()

  initGMap: ->
    map_options =
      zoom: @zoom,
      center: @lat_lon,
      mapTypeId: google.maps.MapTypeId.ROADMAP
#      scrollwheel: false
    _.defaults(@options.map_options, map_options)
    @map = new google.maps.Map(document.getElementById(@options.doom_map), @options.map_options)

    google.maps.event.addListener @map, 'zoom_changed', =>
      @zoom_el.val(@map.getZoom())

  setInputs: (pos) ->
    @lat_el.val(pos.lat())
    @lon_el.val(pos.lng())
    @zoom_el.val(@map.getZoom())

  initMarker: ->
    marker_options =
      position: @lat_lon,
      map: @map,
      draggable: true

    @marker = new google.maps.Marker(marker_options)
    @infowindow = new google.maps.InfoWindow()

    google.maps.event.addListener @marker, 'dragend', (event) =>
      @marker_callback.call(this, event.latLng) if @marker_callback
      @map.setCenter(event.latLng)
      pos = @marker.getPosition()
      @setInputs(pos)

  initAutocomplete: (dom_input='geo_autocomplete') ->
    input = document.getElementById(dom_input)
    opts =
      types: @options.types
      language: I18n.locale
#      componentRestrictions: {country: 'ru'}
    opts.types = @typesByPrefix() if @options.prefix
#    log opts
    autocomplete = new google.maps.places.Autocomplete(input, opts)
    autocomplete.bindTo('bounds', @map)
    google.maps.event.addListener autocomplete, 'place_changed', =>
      place = autocomplete.getPlace()
      @callback.call(this, place) if @callback
      @setPlace(place)

    $('#'+ dom_input).live "keypress", (e) ->
      e.preventDefault() if e.keyCode == 13

  setPlace: (place) =>
    return unless place.geometry
    pos = place.geometry.location
    if place.geometry.viewport
      @map.fitBounds(place.geometry.viewport)
    else
      @map.setCenter(pos)
      @map.setZoom(17)

    @marker.setPosition(pos)
    @setInputs(pos)


  typesByPrefix: ->
    if _.include(['region', 'district', 'sub_district'], @options.prefix)
      ['(regions)']
    else if _.include(['location'], @options.prefix)
      ['(cities)']
    else
      ['geocode']

  initAutocompleteCustom: (dom_input='geo_autocomplete') ->
    input = document.getElementById(dom_input)
    opts =
      types: ['geocode']
#      componentRestrictions: {country: 'ru'}
    autocomplete = new google.maps.places.Autocomplete(input, opts)
    autocomplete.bindTo('bounds', @map)
    google.maps.event.addListener autocomplete, 'place_changed', =>
      place = autocomplete.getPlace()
      @callback.call(this, place) if @callback
      return unless place.geometry
      pos = place.geometry.location
      if place.geometry.viewport
        @map.fitBounds(place.geometry.viewport)
      else
        @map.setCenter(pos)
        @map.setZoom(17)

      @marker.setPosition(pos)
      @setInputs(pos)

    $('#'+ dom_input).live "keypress", (e) ->
      e.preventDefault() if e.keyCode == 13

window.codeLatLng = (lat, lng, callback = null) ->
  window.geocoder ||= new google.maps.Geocoder()
  lat = parseFloat(lat)
  lng = parseFloat(lng)
  latlng = new google.maps.LatLng(lat, lng)
  window.geocoder.geocode {latLng: latlng}, (results, status) ->
    if status is google.maps.GeocoderStatus.OK
#      log results[1]
      results[1]
      callback(results[1]) if callback
    else
      false

window.codeAddress = (address, callback = null) ->
#  log address
  window.geocoder ||= new google.maps.Geocoder()
  window.geocoder.geocode {address: address}, (results, status) ->
    if status is google.maps.GeocoderStatus.OK
#      log results
      callback(_.first(results)) if callback
    else
      false

window.getPlaceComponent = (place, component) ->
  res = _.filter place.address_components, (el) ->
    _.include(el.types, component)
  res[0]


