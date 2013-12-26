#=require fileupload/vendor/jquery.ui.widget
#=require fileupload/jquery.iframe-transport
#=require fileupload/jquery.fileupload
#=require fileupload/jquery.fileupload-process
#=require fileupload/jquery.fileupload-validate
#q=require fileupload/jquery.fileupload-image
#q=require fileupload/jquery.fileupload-audio
#q=require fileupload/jquery.fileupload-video
#=require fileupload/locales/ru

class window.AdminAssets
  constructor: (@options) ->
    @el = $('#' + @options.element_id)
    @initHandlers()

  initHandlers: ->
    defaults =
      dataType: 'json'
      processfail: @processfail

    if @options.alloved_extensions
      defaults.acceptFileTypes = new RegExp("(\.|\/)(#{@options.alloved_extensions.join('|')})", 'i')

    @el.fileupload _.defaults(@options.fileupload, defaults)

  processfail: (e, data) ->
    errors = _.map(data.files,(file) ->
      [file.name, "<b>#{file.error}</b>"].join(' - ')).join('<br/>')
    bootbox.alert(errors)