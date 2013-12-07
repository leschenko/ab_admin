#= require ab_admin/fileupload/fileuploader.js
#= require ab_admin/fileupload/admin-fileuploader.js
#= require jquery.tmpl.min
#q= require ab_admin/jquery.Jcrop
#q= require ab_admin/components/croppable_image

class window.AdminAssets
  constructor: (@element_id, @url, @sortable) ->
    @uploader_api = qq.FileUploader.instances[@element_id]
    @uploader_el = $("##{@element_id}")
    @initHandlers()
    @uploader_el.data('AdminAssets', this)

  initHandlers: ->
    self = this
    @query = "##{@element_id} .fileupload-list"
    if @sortable
      $(".do_sort " + @query).sortable
        revert: true
        update: (event, ui) ->
          data = $(self.query).sortable("serialize")
          $.ajax
            url: self.url
            data: data
            dataType: "script"
            type: "POST"

    if $.fn.fancybox
      @initFancybox()

    unless window.admin_assets_first
      window.admin_assets_first = true
      @initMainImage()
      @initRemove()
      @initRotate()
    @initCrop()
    @initBatchEdit()

  initRemove: ->
    $(document).on "ajax:complete", ".fileupload .del_asset", ->
      $(this).closest("div.asset").remove()

  initMainImage: ->
    $(document).on 'click', '.fileupload.many_assets .main_image', ->
      $asset = $(this).closest('.asset')
      $curr_cont = $asset.closest('.fileupload')
      $curr_list = $curr_cont.find('.fileupload-list')
      asset_klass = $curr_cont.data('asset')
      $main_list = $(".fileupload.one_asset[data-asset='#{asset_klass}'] .fileupload-list:first")

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

  initFancybox: =>
    $(@query + " a.fancybox").fancybox
      afterShow: => @crop?.fancyboxHandler()

  initBatchEdit: ->
    return unless @uploader_el.data('edit-meta')
    @uploader_el.find('.fileupload-edit-button').show()
    @uploader_el.on 'click', '.fileupload-edit-button', =>
      ids = @uploader_el.find('.fileupload-list .asset').map(-> $(this).data('id')).get()
      unless ids[0]
        bootbox.alert 'Upload images first'
      $.get '/admin/assets/batch_edit', {ids: ids}, (data) =>
        bootbox.dialog(data, [
          {label: I18n.t('admin_js.cancel'), class: ' '},
          {label: I18n.t('admin_js.save'), class: 'btn-primary btn-large fileupload-edit-submit', callback: -> $('form.fileupload-edit-form').submit()}
        ])
        $('.bootbox.modal').css
          width: 900
          'margin-left': -450

