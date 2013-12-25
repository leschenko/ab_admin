#=require jquery-fileupload/vendor/jquery.ui.widget
#=require jquery-fileupload/vendor/load-image
#=require jquery-fileupload/vendor/canvas-to-blob
#=require jquery-fileupload/jquery.iframe-transport
#=require jquery-fileupload/jquery.fileupload
#=require jquery-fileupload/jquery.fileupload-fp
#=require ab_admin/fileupload/jquery.fileupload-validate.js
#=require ab_admin/fileupload/jquery.fileupload-process.js
#=require jquery-fileupload/locale

class window.AdminAssets
  constructor: (@options) ->
    @el = $('#' + @options.element_id)
    @initHandlers()

  initHandlers: ->
    defaults =
      dataType: 'json'
      maxFileSize: 100
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i

    log @options
    @el.fileupload _.defaults(@options.fileupload, defaults)

    callbacks = ['fileuploadadd', 'fileuploadsubmit', 'fileuploadsend', 'fileuploaddone', 'fileuploadfail', 'fileuploadalways',
     'fileuploadprogress', 'fileuploadprogressall', 'fileuploadstart', 'fileuploadstop', 'fileuploadchange',
     'fileuploadpaste', 'fileuploaddrop', 'fileuploaddragover', 'fileuploadchunksend']

    for callback in callbacks
      @el.on callback, (e, data) ->
        log callback
        log [e, data]
