#= require fileupload/vendor/jquery.ui.widget
#= require fileupload/jquery.iframe-transport
#= require fileupload/jquery.fileupload
#= require fileupload/jquery.fileupload-process
#= require fileupload/jquery.fileupload-validate

#q= require ab_admin/jquery.Jcrop
#q= require ab_admin/components/croppable_image

#q=require fileupload/jquery.fileupload-image
#q=require fileupload/jquery.fileupload-audio
#q=require fileupload/jquery.fileupload-video

class window.AdminAssets
  constructor: (@options) ->
    @el = $('#' + @options.container_id)
    @el.data('AdminAssets', this)
    @list = @el.find('.fileupload-list')
    @files_in_progress = 0
    @template = Handlebars.compile($("##{@options.asset_template}_template").html())
    @initFileupload()
    @initHandlers()

  initFileupload: ->
    defaults =
      dataType: 'json'
      dropZone: @el
      pasteZone: @el
      processfail: @showErrors
      send: @addFileInProgress
      getNumberOfFiles: =>
        @files_in_progress + @list.find('.asset').length
      done: (e, data) =>
        @list.empty() unless @options.multiple
        @list.append @template(data.result.asset)
      start: =>
        toggleLoading(true)
      always: =>
        @removeFileInProgress()
        toggleLoading(false)

    if @options.extensions
      defaults.acceptFileTypes = new RegExp("(\.|\/)(#{@options.extensions.join('|')})", 'i')

    @el.fileupload _.defaults(@options.fileupload, defaults)

  showErrors: (e, data) ->
    errors = _.map(data.files,(file) ->
      [file.name, "<b>#{file.error}</b>"].join(' - ')).join('<br/>')
    bootbox.alert(errors)

  addFileInProgress: =>
    @files_in_progress += 1

  removeFileInProgress: =>
    @files_in_progress = Math.max(0, @files_in_progress - 1)

  initHandlers: ->
    @initRemove()
    @initRotate()
    @initMainImage() if @options.multiple
    @initSortable() if @options.sortable
    @initFancybox() if $.fn.fancybox
    @initEditMeta() if @options.edit_meta
    @initCrop() if @options.crop

  initRemove: ->
    @el.on 'ajax:complete', '.destroy_asset', ->
      $(this).closest("div.asset").remove()

  initRotate: ->
    self = this
    @el.on 'click', '.rotate_image', ->
      $asset = $(this).closest('.asset')
      $.post "/admin/assets/#{$asset.data('id')}/rotate", (data) ->
        $asset.replaceWith self.template(data.asset)

  initMainImage: ->
    self = this
    @el.on 'click', '.fileupload-multiple .main_image', ->
      $asset = $(this).closest('.asset')
      klass_css = "fileupload-klass-#{self.options.klass}"
      record_css = "fileupload-record-#{self.options.fileupload.formData.guid}"
      $single_list = $(".fileupload.fileupload-single.#{record_css}.#{klass_css} .fileupload-list")

      $.post "/admin/assets/#{$asset.data('id')}/main", ->
        $single_list.find('.asset').appendTo(self.list)
        $asset.appendTo($single_list)

  initSortable: ->
    @list.sortable
      revert: true
      update: =>
        $.post @options.sort_url, @list.sortable('serialize')

  initFancybox: =>
    @list.find(" a.fancybox")
      .click (e) ->
        e.preventDefault()
      .fancybox
        afterShow: =>
          @crop?.fancyboxHandler()
        helpers:
          overlay:
            locked: false

  initCrop: ->
    return unless $.fn.Jcrop
    @crop = new CroppableImage(@el, @options.crop)

  initEditMeta: ->
    @el.find('.fileupload-edit-button').show().click =>
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
        $('.modal-body').css
          'max-height': max_h - 90
