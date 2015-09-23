$.rails.allowAction = (element) ->
  message = element.data("confirm")
  return true unless message
  bootbox.confirm "<h3>#{message}</h3>", (answer) ->
    element.data('confirm', null).click() if answer
  false