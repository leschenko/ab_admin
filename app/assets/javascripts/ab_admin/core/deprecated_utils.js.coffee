Array::last = ->
  if @.length > 0
    @[@.length - 1]

Array::first = ->
  @[0]

Array::removeByIndex = (arrayIndex)->
  @.splice(arrayIndex, 1)

Array::valDetect = (v, prop = 'id') ->
  res = null
  for el in @
    if el[prop] is v
      res = el
  res

Array::includes = (obj) ->
  for el, i in @
    if el == obj
      return i
  return false

Array::remove = ->
  what = undefined
  a = arguments
  L = a.length
  ax = undefined
  while L and @length
    what = a[--L]
    until (ax = @indexOf(what)) is -1
      @splice ax, 1
      break;
  this

String::parseQuery = ->
  h = {}
  qs = $.trim(this).match(/([^?#]*)(#.*)?$/)[0]
  return {}  unless qs
  pairs = qs.split("&")
  $.each pairs, (i, v) ->
    pair = v.split("=")
    h[pair[0]] = pair[1]
  h
