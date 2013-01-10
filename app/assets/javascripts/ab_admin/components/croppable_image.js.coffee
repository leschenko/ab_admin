class window.CroppableImage
  constructor: (@uploader_el) ->
    @uploader_api = qq.FileUploader.instances[@uploader_el.attr('id')]
    @initHandelers()
    @uploader_el.bind 'fileupload:onComplete', @refreshHandlers

  initHandelers: =>
    @el = $('.fileupload-file.fancybox', @uploader_el)
    @fancybox_api = @el.data('fancybox')
    @fancybox_api?.onComplete = @fancyboxHandler
    @fancybox_api?.onClosed = -> $('#fancybox-content').css({'z-index': 1102})

  fancyboxHandler: =>
    $img = $('#fancybox-img')
    $img.Jcrop
      aspectRatio: 760 / 350
      setSelect: [0, 0, 760, 350]
      onSelect: @setCropData
      onChange: @setCropData
    $cont = $('#fancybox-content')
    $cont.css({'z-index': 1103})
    $img.load =>
      setTimeout((=>
        $cont.height (i, v) -> v + 35
        $btn = $("<a href='#' class='btn btn-primary' id='crop_button'>Обрезать</a>")
        $cont.append($btn)
        $btn.click @cropHandler
      ), 300)

  setCropData: (coords) =>
    @cropData = coords

  render: (data) =>
    $(@uploader_api._listElement).html $(@uploader_api._options.template_id).tmpl(data.asset)
    $.fancybox.close()
    @refreshHandlers()

  refreshHandlers: =>
    Manage.initFancybox('#' + @uploader_el.attr('id'))
    @initHandelers()

  cropHandler: (e) =>
    e.preventDefault()
    action = @uploader_api._options.action
    data =
      img_url: @el.attr('href')
      crop_attrs: @cropData
    $.post action, data, @render, 'json'
