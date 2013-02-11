window.initGeoInput = (prefix, autocomplete = true) ->
  opts =
    prefix: prefix
    doom_map: "#{prefix}_map"
    callback: "#{prefix}_geo_callback"
    map_options:
      {scrollwheel: false}
  gmaps = new GeoInput("#{prefix}_lat", "#{prefix}_lon", "#{prefix}_zoom", opts)
  gmaps.initAutocomplete("#{prefix}_geo_autocomplete") if autocomplete

window.clonePagination = ->
  $('.pagination:first').clone().appendTo($('.batch_actions'))

window.initPopover = ->
  $('.popover').hide()
  $('a[rel=popover]').popover({trigger: 'hover'})

window.initChosen = ->
  return if gon.test
  chosen_options =
    allow_single_deselect: true
    no_results_text: I18n.t('admin_js.no_results')
    placeholder_text_single: ' '
    placeholder_text_multiple: ' '
  $('form .do_chosen, .without_form.do_chosen, form .do_chosen_multi').chosen(chosen_options)

window.initAcFileds = ->
  for el in $('.ac_field')
    $el = $(el)
    params = $.extend({class: $el.data('class')}, $el.data('params') || {})
    $(el).oautocomplete
      serviceUrl: '/admin/autocomplete'
      params: params
      minChars: 2
      maxHeight: 400
      width: 220

window.initTooltip = ->
  $('.do_tooltip').tooltip
    animation: false
    placement: 'right'

window.initEditor = ->
  return if gon.test
  $('form .do_wysihtml5').each ->
    $el = $(this)
    return if $el.hasClass('wysihtml5_done')
    editor = $el.wysihtml5({html: true, locale: 'ru'}).data('wysihtml5').editor
    resizeIframe = -> editor.composer.iframe.style.height = editor.composer.element.scrollHeight + "px"
    editor.on "load", ->
      if editor.composer
        editor.composer.element.addEventListener "keyup", resizeIframe, false
        editor.composer.element.addEventListener "blur", resizeIframe, false
        editor.composer.element.addEventListener "focus", resizeIframe, false
    $el.addClass('wysihtml5_done')

window.inputSetToggle = ->
  $('.label.do_toggle').click ->
    $(this).siblings().toggle()

window.flash = (type, message) ->
  $('#wrap').prepend $("<div class='alert alert-#{type}'><a class='close' data-dismiss='alert'>×</a>#{message}</div>")

window.focusInput = ->
  $('input[type="text"],input[type="string"],select:visible,textarea:visible', $('form.simple_form:first')).get(0)?.focus()