#= require ab_admin/components/select2_bridge

window.clonePagination = ->
  $('.pagination:first').clone().appendTo($('.batch_actions'))

window.initPopover = ->
  $('.popover').hide()
  $('a[rel=popover]').popover({trigger: 'hover', html: true})

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

window.flash = (message, type='notice') ->
  $("<div class='alert alert-#{type}'><a class='close' data-dismiss='alert'>×</a>#{message}</div>").insertBefore $('#container')

window.focusInput = (scope=null) ->
  scope ||= $('form.simple_form:first')
  $('input[type="text"],input[type="string"],select:visible,textarea:visible', scope).not('.fancy_select,.datepicker').get(0)?.focus()

window.templateStorage = {}
window.fetchTemplate = (tmpl_id) ->
  window.templateStorage[tmpl_id] ||= Handlebars.compile($(tmpl_id).html())

window.initFancySelect = ->
  $('form .fancy_select, form input.token, .without_form.fancy_select').each ->
    $el = $(this)
    $el.data('Select2Bridge') or $el.data('Select2Bridge', new Select2Bridge($el))
