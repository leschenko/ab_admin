$.rails.allowAction = (element) ->
  message = "<h3>#{element.data("confirm")}</h3>"
  return true unless message
  bootbox.confirm message, (answer) ->
    element.data('confirm', null).click() if answer
  false