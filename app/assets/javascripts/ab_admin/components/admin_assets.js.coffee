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
    @list = $(@list_query)
    @template = Handlebars.compile($("##{@options.file_type}_template").html())
    @initFileupload()
    @initHandlers()

  initFileupload: ->
    defaults =
      dataType: 'json'
      processfail: @showErrors
      done: (e, data) =>
        @renderAsset(data.result.asset)

    if @options.extensions
      defaults.acceptFileTypes = new RegExp("(\.|\/)(#{@options.extensions.join('|')})", 'i')

    @el.fileupload _.defaults(@options.fileupload, defaults)

  showErrors: (e, data) ->
    errors = _.map(data.files,(file) ->
      [file.name, "<b>#{file.error}</b>"].join(' - ')).join('<br/>')
    bootbox.alert(errors)

  renderAsset: (asset) ->
    @list.empty() unless @options.multiple
    @list.append @template(asset)

  initHandlers: ->
    unless window.admin_assets_first
      window.admin_assets_first = true
      @initRemove()
      @initMainImage()
    @initRotate()
    @initSortable() if @options.sortable
    @initFancybox() if $.fn.fancybox
    @initEditMeta() if @options.edit_meta

  initRemove: ->
    $(document).on 'ajax:complete', '.fileupload .destroy_asset', ->
      $(this).closest("div.asset").remove()

  initMainImage: ->
    @el.on 'click', '.fileupload-multiple .main_image', ->
      $asset = $(this).closest('.asset')
      $multiple_list = $asset.closest('.fileupload').find('.fileupload-list')
      klass_css = "fileupload-klass-#{@options.klass}"
      record_css = "fileupload-record-#{@options.fileupload.formData.guid}"
      $single_list = $(".fileupload.fileupload-single.#{record_css}.#{klass_css} .fileupload-list")

      $.post "/admin/assets/#{$asset.data('id')}/main", ->
        $single_list.find('.asset').appendTo($multiple_list)
        $asset.appendTo($single_list)

  initRotate: ->
    self = this
    @el.on 'click', '.rotate_image', ->
      $asset = $(this).closest('.asset')
      $.post "/admin/assets/#{$asset.data('id')}/rotate", (data) ->
        self.renderAsset(data.asset)

  initSortable: ->
    @list.sortable
      revert: true
      update: ->
        $.post self.options.sort_url, {data: $(self.list_query).sortable('serialize')}

  initFancybox: =>
    @list.find(" a.fancybox").fancybox
      afterShow: =>
        @crop?.fancyboxHandler()

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
