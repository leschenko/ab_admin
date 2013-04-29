class window.CroppableImage
  @crop_defaults = {}
#    aspectRatio: 760 / 350
#    setSelect: [0, 0, 760, 350]

  constructor: (@element_id, @options = {}) ->
    @uploader_api = qq.FileUploader.instances[@element_id]

  fancyboxHandler: =>
    _.defaults(@options, CroppableImage.crop_defaults)
    @options.onSelect = @setCropData
    @options.onChange = @setCropData

    $('.fancybox-image:first').Jcrop @options
    $('.fancybox-nav').hide()

    $cont = $('.fancybox-outer:first')
    $btn = $("<a href='#' class='btn btn-primary' id='crop_button'>Обрезать</a>")
    $cont.append($btn)
    $btn.click @cropHandler

  setCropData: (coords) =>
    @cropData = coords

  cropHandler: (e) =>
    e.preventDefault()
    asset_id = $('.fancybox-image:first').attr('src').match(/\d+/)
    $asset = $("#asset_#{asset_id}")
    geometry = [@cropData['w'], @cropData['h'], @cropData['x'], @cropData['y']].join(',')
    $.post "/admin/assets/#{$asset.data('id')}/crop", {geometry: geometry}, (data) =>
      $asset.replaceWith $(@uploader_api._options.template_id).tmpl(data.asset)
      $.fancybox.close()