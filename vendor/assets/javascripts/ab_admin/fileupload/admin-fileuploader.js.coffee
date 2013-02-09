qq.FileUploader.instances = new Object()
qq.FileUploaderInput = (o) ->
  qq.FileUploaderBasic.apply this, arguments
  qq.extend @_options,
    element: null
    listElement: null
    template_id: "#fileupload_tmpl"
    classes:
      button: "fileupload-button"
      drop: "fileupload-drop-area"
      dropActive: "fileupload-drop-area-active"
      list: "fileupload-list"
      preview: "fileupload-preview"
      file: "fileupload-file"
      spinner: "fileupload-spinner"
      size: "fileupload-size"
      cancel: "fileupload-cancel"
      success: "fileupload-success"
      fail: "fileupload-fail"

  qq.extend @_options, o
  @_element = document.getElementById(@_options.element)
  @_listElement = @_options.listElement or @_find(@_element, "list")
  @_classes = @_options.classes
  @_button = @_createUploadButton(@_find(@_element, "button"))
  qq.FileUploader.instances[@_element.id] = this

qq.extend qq.FileUploaderInput::, qq.FileUploaderBasic::
qq.extend qq.FileUploaderInput::,
  _find: (parent, type) ->
    element = qq.getByClass(parent, @_options.classes[type])[0]
    throw new Error("element not found " + type)  unless element
    element

  _setupDragDrop: ->
    self = this
    dropArea = @_find(@_element, "drop")
    dz = new qq.UploadDropZone(
      element: dropArea
      onEnter: (e) ->
        qq.addClass dropArea, self._classes.dropActive
        e.stopPropagation()

      onLeave: (e) ->
        e.stopPropagation()

      onLeaveNotDescendants: (e) ->
        qq.removeClass dropArea, self._classes.dropActive

      onDrop: (e) ->
        dropArea.style.display = "none"
        qq.removeClass dropArea, self._classes.dropActive
        self._uploadFileList e.dataTransfer.files
    )
    dropArea.style.display = "none"
    qq.attach document, "dragenter", (e) ->
      return  unless dz._isValidFileDrag(e)
      dropArea.style.display = "block"

    qq.attach document, "dragleave", (e) ->
      return  unless dz._isValidFileDrag(e)
      relatedTarget = document.elementFromPoint(e.clientX, e.clientY)
      dropArea.style.display = "none"  if not relatedTarget or relatedTarget.nodeName is "HTML"

  _onSubmit: (id, fileName) ->
    qq.FileUploaderBasic::_onSubmit.apply this, arguments
    @_addToList id, fileName

  _onProgress: (id, fileName, loaded, total) ->
    qq.FileUploaderBasic::_onProgress.apply this, arguments

  _onComplete: (id, fileName, result) ->
    qq.FileUploaderBasic::_onComplete.apply this, arguments
    item = @_getItemByFileId(id)
    asset = result.asset
    if asset and asset.id
      qq.addClass item, @_classes.success
      $(item).replaceWith $(@_options.template_id).tmpl(asset)
      @_trigger_event asset
    else
      qq.addClass item, @_classes.fail
    $('.fileupload-drop-area').hide()

  _trigger_event: (asset) ->
    $("#" + @_options.element).trigger
      type: "fileupload:onComplete"
      asset: asset

  _addToList: (id, fileName) ->
    if @_listElement
      $(@_listElement).empty()  if @_options.multiple is false
      asset =
        id: 0
        filename: @_formatFileName(fileName)
        url: "/assets/admin/preloader.gif"
        thumb_url: "/assets/admin/preloader.gif"

      item = $(@_options.template_id).tmpl(asset).attr("qqfileid", id).appendTo(@_listElement)
      @_bindCancelEvent item

  _getItemByFileId: (id) ->
    $(@_listElement).find("div[qqfileid=" + id + "]").get 0

  _bindCancelEvent: (element) ->
    self = this
    item = $(element)
    item.find("a." + @_classes.cancel).bind "click", (e) ->
      self._handler.cancel item.attr("qqfileid")
      item.remove()
      qq.preventDefault e
      false