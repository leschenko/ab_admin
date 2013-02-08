class window.SettingsEditor
  constructor: ->
    @initHandlers()

  initHandlers: ->
    $('#advanced_mode').click ->
      $('.advanced').toggle()