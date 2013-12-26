#=require fileupload/vendor/jquery.ui.widget
#=require fileupload/jquery.iframe-transport
#=require fileupload/jquery.fileupload
#=require fileupload/jquery.fileupload-process
#=require fileupload/jquery.fileupload-validate
#q=require fileupload/jquery.fileupload-image
#q=require fileupload/jquery.fileupload-audio
#q=require fileupload/jquery.fileupload-video

class window.AdminAssets
  constructor: (@options) ->
    @el = $('#' + @options.container_id)
    @el.data('AdminAssets', this)
    @list_query = "##{@options.container_id} .fileupload-list"
    @initHandlers()
    @initSortable() if @options.sortable
    @initFancybox() if $.fn.fancybox
    @initEditMeta() if @options.edit_meta

  initHandlers: ->
    defaults =
      dataType: 'json'
      processfail: @processfail

    if @options.extensions
      defaults.acceptFileTypes = new RegExp("(\.|\/)(#{@options.extensions.join('|')})", 'i')

    @el.fileupload _.defaults(@options.fileupload, defaults)

  processfail: (e, data) ->
    errors = _.map(data.files,(file) ->
      [file.name, "<b>#{file.error}</b>"].join(' - ')).join('<br/>')
    bootbox.alert(errors)

  initSortable: ->
    $(".fileupload-sortable " + @list_query).sortable
      revert: true
      update: ->
        $.post self.options.sort_url, {data: $(self.list_query).sortable("serialize")}

  initFancybox: =>
    $(@list_query + " a.fancybox").fancybox
      afterShow: =>
        @crop?.fancyboxHandler()

  initRemove: ->
    $(document).on 'ajax:complete', '.fileupload .destroy_asset', ->
      $(this).closest("div.asset").remove()

  initMainImage: ->
    $(document).on 'click', '.fileupload.fileupload-multiple .main_image', ->
      $asset = $(this).closest('.asset')
      $curr_cont = $asset.closest('.fileupload')
      $curr_list = $curr_cont.find('.fileupload-list')
      $main_list = $(".fileupload.fileupload-single.fileupload-klass-#{@options.klass} .fileupload-list:first")

      $.post "/admin/assets/#{$asset.data('id')}/main", ->
        $main_list.find('.asset').appendTo($curr_list)
        $asset.appendTo($main_list)

  initRotate: ->
    $(document).on 'click', '.fileupload .rotate_image', ->
      $asset = $(this).closest('.asset')
      $uploader = qq.FileUploader.instances[$asset.closest('.fileupload').attr('id')]
      $.post "/admin/assets/#{$asset.data('id')}/rotate", (data) ->
        $asset.replaceWith $($uploader._options.template_id).tmpl(data.asset)

  initCrop: ->
    if @uploader_el.data('crop') && $.fn.Jcrop
      opts = if _.isObject(@uploader_el.data('crop')) then @uploader_el.data('crop') else {}
      @crop = new CroppableImage(@element_id, opts)

  initEditMeta: ->
    @el.find('.fileupload-edit-button').show()
    @el.on 'click', '.fileupload-edit-button', =>
      ids = @el.find('.fileupload-list .asset').map(-> $(this).data('id')).get()
      unless ids[0]
        bootbox.alert 'Upload images first'
      $.get '/admin/assets/batch_edit', {ids: ids}, (data) =>
        bootbox.dialog(data, [
          {label: I18n.t('admin.js.cancel'), class: ' '},
          {label: I18n.t('admin.js.save'), class: 'btn-primary btn-large fileupload-edit-submit', callback: -> $('form.fileupload-edit-form').submit()}
        ])
        max_h = $(window).height() - 100
        $('.bootbox.modal').css
          height: max_h
          width: 900
          'margin-left': -450
          'margin-top': -max_h / 2
        $('.modal-body').css
          'max-height': max_h - 90
