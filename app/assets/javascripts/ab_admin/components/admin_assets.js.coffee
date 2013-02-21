#= require ab_admin/fileupload/fileuploader.js
#= require ab_admin/fileupload/admin-fileuploader.js
#= require jquery.tmpl.min
#q= require ab_admin/jquery.Jcrop
#= require ab_admin/components/croppable_image

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

  initRemove: ->
    $(document).on "ajax:complete", ".fileupload .del_asset", ->
      $(this).closest("div.asset").remove()

  initMainImage: ->
    $(document).on 'click', '.fileupload.many_assets .main_image', ->
      $asset = $(this).closest('.asset')
      $curr_cont = $asset.closest('.fileupload')
      $curr_list = $curr_cont.find('.fileupload-list')
      asset_klass = $curr_cont.data('asset')
      $main_list = $(".fileupload.one_asset[data-asset='#{asset_klass}'] .fileupload-list")

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
      @crop = new CroppableImage(@element_id)

  initFancybox: =>
    $(@query + " a.fancybox").fancybox
      afterShow: => @crop?.fancyboxHandler()


#class window.AssetDescription
#  constructor: (@assoc, @assetable_type, @assetable_id, @guid) ->
#    @cont = $("[id^='#{@assoc}_']")
#    @addButton()
#
#  addButton: ->
#    uri = $.param({assoc: @assoc, assetable_type: @assetable_type, assetable_id: @assetable_id, guid: @guid})
#    url = '/admin/assets/description?' + uri
#    html = "<button type='button' class='black_button button_description' href='#{url}'>#{I18n.t('admin_js.button_description')}</button>"
#    @cont.find('.fileupload-button').after(html)
#    @button = @cont.find('.button_description')
#    @button.fancybox
#      onComplete: ->
#        $cont = $(".locale_tabs.asset_description")
##        $cont.tabs()
#        $cont.closest('#fancybox-content').width (i, w) -> w + 10
#    $('#fancybox-content .button_save, #fancybox-content .button_cancel').live 'click', ->
#      $.fancybox.close()
#
