class window.CroppableImage
  @crop_defaults = {}
#    aspectRatio: 760 / 350
#    setSelect: [0, 0, 760, 350]

  constructor: (@el, @options = {}) ->
    @options = {} unless _.isObject(@options)

  fancyboxHandler: =>
    _.defaults(@options, CroppableImage.crop_defaults)
    @options.onSelect = @setCropData
    @options.onChange = @setCropData
    $img = $('.fancybox-image:first')
    @natural_size =
      w: $img[0].naturalWidth
      h: $img[0].naturalHeight
    @current_size =
      w: $img.width()
      h: $img.height()
    $img.Jcrop @options
    $('.fancybox-nav').hide()

    $cont = $('.fancybox-outer:first')
    $btn = $("<a href='#' class='btn btn-primary' id='crop_button'>Обрезать</a>")
    $cont.append($btn)
    $btn.click @cropHandler

  setCropData: (coords) =>
    @cropData = coords

  cropHandler: (e) =>
    e.preventDefault()
    asset_id = to_i($('.fancybox-image:first').attr('src').match(/\/[\d\/]{2,}\//)[0].replace(/\//g, ''))
    $asset = $(@options.asset_selector || "#asset_#{asset_id}")
    @scalingCrop()
    geometry = [@cropData['w'], @cropData['h'], @cropData['x'], @cropData['y']].join(',')
    $.post "/admin/assets/#{asset_id}/crop", {geometry: geometry}, (data) =>
      $asset.replaceWith @el.data('assets').template(data.asset)
      $.fancybox.close()

  scalingCrop: ->
    return unless @natural_size['w'] > @current_size['w'] && @natural_size['h'] > @current_size['h']
    w_factor = @natural_size['w'] / @current_size['w']
    h_factor = @natural_size['h'] / @current_size['h']
    @cropData['x'] = Math.ceil(@cropData['x'] * h_factor) if @cropData['x'] > 0
    @cropData['y'] = Math.ceil(@cropData['y'] * w_factor) if @cropData['y'] > 0

    @cropData['w'] = Math.ceil(@current_size['w'] * w_factor )
    @cropData['h'] = Math.ceil(@cropData['h'] * h_factor )