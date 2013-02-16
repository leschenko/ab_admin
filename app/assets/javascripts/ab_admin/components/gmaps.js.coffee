class window.GeoInput
  @default_lat = 55.7427928
  @default_lon = 55.7427928

  constructor: (@cont, @options={}) ->
    @prefix = @cont.attr('id').replace(/_geo_input$/, '')
    defaults =
      lat: GeoInput.default_lat
      lon: GeoInput.default_lon
      autocomplete: true

    _.defaults(@options, defaults)

    @initElements()
    @initPoint()
    @initMap()
    @initMarker()
    @initHandlers()
    @initAutocomplete() if @options.autocomplete

  initElements: ->
    for el in ['lat', 'lon', 'map', 'zoom', 'geo_ac']
      @options["#{el}_id"] ||= "#{@prefix}_#{el}"
      this["#{el}_el"] = $("##{@options["#{el}_id"]}")

  initPoint: ->
    @lat = parseFloat(@lat_el.val()) or @options.lat
    @lon = parseFloat(@lon_el.val()) or @options.lon
    @zoom = parseInt(@zoom_el.val(), 10) or 12
    @point = new google.maps.LatLng(@lat, @lon)

  initHandlers: ->
    @cont.bind 'geo_input:zoom_changed', (e) =>
      @zoom_el.val(e.zoom)

    @cont.bind 'geo_input:dragend', (e) =>
      @map.setCenter(e.point)
      @setInputs(e.point)

    @cont.bind 'geo_input:place_changed', (e) =>
      @setPlace(e.place)

    @geo_ac_el.keypress (e) ->
      e.preventDefault() if e.keyCode == 13

  setPlace: (place) =>
    return unless place.geometry
    point = place.geometry.location
    if place.geometry.viewport
      @map.fitBounds(place.geometry.viewport)
    else
      @map.setCenter(point)
      @map.setZoom(17)

    @marker.setPosition(point)
    @setInputs(point)

  setInputs: (point) ->
    @lat_el.val(point.lat())
    @lon_el.val(point.lng())
    @zoom_el.val(@map.getZoom())

  initMap: ->
    map_defaults =
      zoom: @zoom,
      center: @point,
      mapTypeId: google.maps.MapTypeId.ROADMAP
      scrollwheel: false

    @options.map_options ||= {}
    _.defaults(@options.map_options, map_defaults)
    @map = new google.maps.Map(@map_el[0], @options.map_options)

    google.maps.event.addListener @map, 'zoom_changed', =>
      @cont.trigger
        type: 'geo_input:zoom_changed'
        zoom: @map.getZoom()

  initMarker: ->
    marker_defaults =
      position: @point,
      map: @map,
      draggable: true

    @options.marker_options ||= {}
    _.defaults(@options.marker_options, marker_defaults)

    @marker = new google.maps.Marker(@options.marker_options)
    @infowindow = new google.maps.InfoWindow()

    google.maps.event.addListener @marker, 'dragend', (e) =>
      @cont.trigger
        type: 'geo_input:dragend'
        point: e.latLng

  initAutocomplete: ->
    geo_ac_defaults =
      language: I18n.locale
      types: ['geocode']

    @options.geo_ac_options ||= {}
    _.defaults(@options.geo_ac_options, geo_ac_defaults)
    autocomplete = new google.maps.places.Autocomplete(@geo_ac_el[0], @options.geo_ac_options)
    autocomplete.bindTo('bounds', @map)
    google.maps.event.addListener autocomplete, 'place_changed', =>
      @cont.trigger
        type: 'geo_input:place_changed'
        place: autocomplete.getPlace()

$.fn.geoInput = (options) ->
  $el = $(this)
  $el.data('geoInput') or $el.data('geoInput', new GeoInput($el, options))


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



#  typesByPrefix: ->
#    if _.include(['region', 'district', 'sub_district'], @options.prefix)
#      ['(regions)']
#    else if _.include(['location'], @options.prefix)
#      ['(cities)']
#    else
#      ['geocode']

#  initAutocompleteCustom: (dom_input='geo_autocomplete') ->
#    input = document.getElementById(dom_input)
#    opts =
#      types: ['geocode']
##      componentRestrictions: {country: 'ru'}
#    autocomplete = new google.maps.places.Autocomplete(input, opts)
#    autocomplete.bindTo('bounds', @map)
#    google.maps.event.addListener autocomplete, 'place_changed', =>
#      place = autocomplete.getPlace()
#      @callback.call(this, place) if @callback
#      return unless place.geometry
#      pos = place.geometry.location
#      if place.geometry.viewport
#        @map.fitBounds(place.geometry.viewport)
#      else
#        @map.setCenter(pos)
#        @map.setZoom(17)
#
#      @marker.setPosition(pos)
#      @setInputs(pos)
#
#    $('#'+ dom_input).live "keypress", (e) ->
#      e.preventDefault() if e.keyCode == 13

