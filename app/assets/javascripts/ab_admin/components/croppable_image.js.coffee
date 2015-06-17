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
    @options.trueSize = [$img[0].naturalWidth, $img[0].naturalHeight]
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
    geometry = [@cropData['w'], @cropData['h'], @cropData['x'], @cropData['y']].join(',')
    $.post "/admin/assets/#{asset_id}/crop", {geometry: geometry}, (data) =>
      $asset.replaceWith @el.data('assets').template(data.asset)
      $.fancybox.close()