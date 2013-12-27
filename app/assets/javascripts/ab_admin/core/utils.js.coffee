window.gon ||= {}
window.I18n ||= {}
I18n.locale = window.gon.locale || 'ru'
window.locale_path = if I18n.locale == 'ru' then '' else "/#{I18n.locale}"

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

_.indexBy = (obj, value, context) ->
  res = _.groupBy(obj, value, context)
  for k, v of res
    res[k] = v[0]
  res

_.timeout = (timeout, fn) ->
  setTimeout(fn, timeout)

_.interval = (timeout, fn) ->
  setInterval(fn, timeout)

# execute function periodically while it return false
_.tryInterval = (timeout, fn) ->
  proxy_fn = ->
    clearInterval(try_interval_id) if fn.call()
  try_interval_id = setInterval(proxy_fn, timeout)

$.fn.serializeJSON = ->
  json = {}
  jQuery.map $(this).serializeArray(), (n) ->
    json[n["name"]] = n["value"]

  json

$.fn.or = (fallbackSelector) ->
  if @length
    this
  else
    $(fallbackSelector || 'body')

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

$.fn.scrollToEl = (speed='slow') ->
  return unless $(this)[0]
  top = $(this).offset().top - to_i($('.navbar-fixed-top').height()) - 2 * to_i($('#list > thead').height())
  $('html, body').stop(true, true).animate({scrollTop: top}, speed)

$.fn.toHref = ->
  $el = $(this)
  if _.isEmpty($el.data())
    window.location.href = $el.attr('href') if $el.attr('href')
  else
    $el.click()

$.fn.toggleClassRadio = (class_name = 'active', state = undefined) ->
  @each ->
    $(this).toggleClass(class_name, state).siblings().removeClass(class_name)

$.parseQuery = ->
  $.parseQueryParams window.location.search.replace("?", "").parseQuery()

$.parseQueryParams = (string) ->
  h = {}
  qs = $.trim(string).match(/([^?#]*)(#.*)?$/)[0]
  return {}  unless qs
  pairs = qs.split("&")
  $.each pairs, (i, v) ->
    pair = v.split("=")
    h[pair[0]] = pair[1]
  h


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

window.to_fixed = (val, prec = 2) ->
  return 0 unless val
  (parseFloat(val) + 0.0).toFixed(prec)

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

window.storeData = (key, data) ->
  if _.isObject(data)
    str = JSON.stringify(data)
  else
    str = '' + data
  if window.localStorage
    window.localStorage[key] = str
  else
    $.cookie(key, str, {path: '/'})

window.fetchData = (key) ->
  window.localStorage?[key] or $.cookie(key)
