window.gon ||= {}
I18n.locale = window.gon.locale || 'ru'
window.locale_path = if I18n.locale == 'ru' then '' else "/#{I18n.locale}"

# undescore
_.sum = (obj) ->
  return 0  if not $.isArray(obj) or obj.length is 0
  _.reduce obj, (sum, n) ->
    sum += n

_.inGroups = (array, number, fill_with=null) ->
  res = []
  max_per = to_i(array.length / number)
  over = to_i(array.length % number)
  max_per += 1 if over > 0
  start = 0
  curr_per = max_per
  _.times number, (i) ->
    curr_per -= 1 if over > 0 && over == i
    end = start + curr_per
    res.push array.slice(start, end)
    start = end
  if fill_with
    for group in res
      while group.length != max_per
        group.push fill_with
  res

_.inGroupsOf = (array, number, fill_with=null) ->
  res = []
  for el, i in array
    res.push [] if i % number == 0
    res.last().push el
  if fill_with && res.last()?.length != number
    while res.last().length != number
      res.last().push fill_with
  res

# jquery
$.fn.serializeJSON = ->
  json = {}
  jQuery.map $(this).serializeArray(), (n) ->
    json[n["name"]] = n["value"]

  json

$.fn.unescape = ->
  $(this).html $.unescape($(this).html())

$.unescape = (html) ->
  htmlNode = document.createElement("div")
  htmlNode.innerHTML = html
  return htmlNode.innerText  if htmlNode.innerText
  htmlNode.textContent

$.fn.emptySelect = ->
  @each ->
    @options.length = 0  if @tagName is "SELECT"

$.fn.loadSelect = (optionsDataArray) ->
  @emptySelect().each ->
    if @tagName is "SELECT"
      selectElement = this
      $.each optionsDataArray, (index, optionData) ->
        option = new Option(optionData.caption, optionData.value)
        if $.browser.msie
          selectElement.add option
        else
          selectElement.add option, null

$.fn.scrollToEl = ->
  $('html, body').animate({scrollTop: $(this).offset().top}, 'slow')

$.parseQuery = ->
  window.location.search.replace("?", "").parseQuery()

# core types
String::parseQuery = ->
  h = {}
  qs = $.trim(this).match(/([^?#]*)(#.*)?$/)[0]
  return {}  unless qs
  pairs = qs.split("&")
  $.each pairs, (i, v) ->
    pair = v.split("=")
    h[pair[0]] = pair[1]
  h

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

# global
window.replaceURLWithHTMLLinks = (text) ->
  exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
  text.replace(exp, "<a href='$1' target='_blank'>$1</a>")

window.to_i = (val) ->
  unless val
    return 0
  val = parseInt val, 10
  if isNaN(val) then 0 else val

window.to_f = (val) ->
  unless val
    return 0.0
  val = parseFloat val, 10
  if isNaN(val) then 0.0 else val

window.log = (objects...) ->
  window.logging = true
  unless window.gon?.no_log
    console.log '== debug ==='
    objects = objects[0] if objects.length == 1
    console.log objects
  window.logging = false

window.clone_obj = (obj) ->
  if notobj? or typeof obj isnt 'object'
    return obj

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone_obj obj[key]

  return newInstance