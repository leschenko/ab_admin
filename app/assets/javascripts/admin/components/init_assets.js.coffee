window.Manage =
  init_assets: (element_id, url, sortable) ->
    query = "#" + element_id + " div.galery"
    if sortable
      $(".do_sort " + query).sortable
        revert: true
        start: (e, ui) ->
          ui.item.addClass "drag_sort"

        update: (event, ui) ->
          data = $(query).sortable("serialize")
          $.ajax
            url: url
            data: data
            dataType: "script"
            type: "POST"

    Manage.initFancybox(query)

  initFancybox: (query) ->
    $(query + " a.fancybox").fancybox
      titleShow: false
      transitionIn: "none"
      transitionOut: "none"
      autoScale: false
      onStart: (items, index, opts) ->
        obj = $(items[index]).parent()
        if obj.hasClass("drag_sort")
          obj.removeClass "drag_sort"
          false

$ ->
  $(".fileupload .asset a.del").live "ajax:complete", ->
    $(this).closest("div.asset").remove()


class window.AssetDescription
  constructor: (@assoc, @assetable_type, @assetable_id, @guid) ->
    @cont = $("[id^='#{@assoc}_']")
    @addButton()

  addButton: ->
    uri = $.param({assoc: @assoc, assetable_type: @assetable_type, assetable_id: @assetable_id, guid: @guid})
    url = '/admin/assets/description?' + uri
    html = "<button type='button' class='black_button button_description' href='#{url}'>#{I18n.t('admin_js.button_description')}</button>"
    @cont.find('.fileupload-button').after(html)
    @button = @cont.find('.button_description')
    @button.fancybox
      onComplete: ->
        $cont = $(".locale_tabs.asset_description")
#        $cont.tabs()
        $cont.closest('#fancybox-content').width (i, w) -> w + 10
    $('#fancybox-content .button_save, #fancybox-content .button_cancel').live 'click', ->
      $.fancybox.close()

