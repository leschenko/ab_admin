$.rails.allowAction = (element) ->
  message = element.data("confirm")
  return true unless message
  bootbox.confirm message, (answer) ->
    element.data('confirm', null).click() if answer
  false