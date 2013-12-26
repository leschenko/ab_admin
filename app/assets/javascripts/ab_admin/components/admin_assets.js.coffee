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
    @initHandlers()

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