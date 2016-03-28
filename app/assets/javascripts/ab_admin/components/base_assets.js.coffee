class window.BaseAssets
  constructor: (@options) ->
    @el = $('#' + @options.container_id)
    @el.data('assets', this)
    @list = @el.find('.fileupload-list')
    if @options.disabled
      @initDisabled()
    else
      @initEnabled()

  initDisabled: ->
    @el.find('.destroy_asset, .rotate_image, .main_image').hide()

  initEnabled: ->
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
        asset = data.result.asset
        @renderAsset(asset)
        @el.trigger('ab_admin:fileupload:done', [asset])
      start: =>
        toggleLoading(true)
      always: =>
        @removeFileInProgress()
        toggleLoading(false)

    if @options.extensions
      defaults.acceptFileTypes = new RegExp("(\.|\/)(#{@options.extensions.join('|')})", 'i')

    @el.fileupload _.defaults(@options.fileupload, defaults)

  addFileInProgress: =>
    @files_in_progress += 1

  removeFileInProgress: =>
    @files_in_progress = Math.max(0, @files_in_progress - 1)

  renderAsset: (asset) ->
    @list.empty() unless @options.multiple
    @list.append @assetHtml(asset)

  assetHtml: (asset) ->
    @template(asset)

  showErrors: (e, data) ->
    errors = _.map(data.files,(file) -> [file.name, file.error].join(' - ')).join(', ')
    alert(errors)

  initHandlers: ->
    @initRemove()
    @initRotate()
    @initMainImage() if @options.multiple
    @initSortable() if @options.sortable

  initRemove: ->
    @el.on 'ajax:complete', '.destroy_asset', ->
      $(this).closest('.fileupload-asset').remove()

  initRotate: ->
    self = this
    @el.on 'click', '.rotate_image', ->
      $asset = $(this).closest('.fileupload-asset')
      $.post "/admin/assets/#{$asset.data('id')}/rotate", (data) ->
        $asset.replaceWith self.assetHtml(data.asset)

  initMainImage: ->
    self = this
    @el.on 'click', '.main_image', ->
      log 'initMainImage'
      $asset = $(this).closest('.fileupload-asset')
      klass_css = "fileupload-klass-#{self.options.klass}"
      record_css = "fileupload-record-#{self.options.fileupload.formData.guid}"
      $single_list = $(".fileupload.fileupload-single.#{record_css}.#{klass_css} .fileupload-list")

      $.post "/admin/assets/#{$asset.data('id')}/main", ->
        $single_list.find('.fileupload-asset').appendTo(self.list)
        $asset.appendTo($single_list)

  initSortable: ->
    @list.sortable
      revert: true
      update: =>
        $.post @options.sort_url, @list.sortable('serialize')