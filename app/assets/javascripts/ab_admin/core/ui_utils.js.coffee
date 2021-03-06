#= require ab_admin/components/select2_bridge

window.clonePagination = ->
  $pagination = $('.pagination-wrap:not(".pagination-cloned"):first')
  if $pagination[0]
    $wrap = $('.content_actions')
    $wrap.find('.pagination-wrap').remove()
    $pagination.clone().addClass('pagination-cloned').appendTo($wrap)

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

window.initEditor = (baseSelector='form') ->
  return if fv.test
  $("#{baseSelector} .do_wysihtml5").each ->
    $el = $(this)
    return if $el.hasClass('wysihtml5_done')
    editor = $el.wysihtml5({html: true, locale: 'en'}).data('wysihtml5').editor
    resizeIframe = -> editor.composer.iframe.style.height = editor.composer.element.scrollHeight + "px"
    editor.on "load", ->
      if editor.composer
        editor.composer.element.addEventListener "keyup", resizeIframe, false
        editor.composer.element.addEventListener "blur", resizeIframe, false
        editor.composer.element.addEventListener "focus", resizeIframe, false
    $el.addClass('wysihtml5_done')

window.inputSetToggle = ->
  $(document).on 'click', '.label.do_toggle', ->
    $(this).siblings().toggle()

window.inputBtnClose = ->
  $(document).on 'click', '.btn-close', (e) ->
    e.preventDefault()
    $(this).closest('.close-wrap').remove()

window.flash = (message, type='notice') ->
  $("<div class='alert alert-#{type}'><a class='close' data-dismiss='alert'>×</a>#{message}</div>").prependTo $('#flash')

window.focusInput = (scope=null) ->
  scope ||= $('form.simple_form:first')
  $('input[type="text"],input[type="string"],select:visible,textarea:visible', scope).not('.fancy_select,.datepicker').get(0)?.focus()

window.templateStorage = {}
window.fetchTemplate = (tmpl_id) ->
  window.templateStorage[tmpl_id] ||= Handlebars.compile($(tmpl_id).html())

window.initFancySelect = ->
  $('form .fancy_select, form input.token, .without_form.fancy_select').each ->
    $el = $(this)
    return if $el.data('select2')
    $el.data('Select2Bridge') or $el.data('Select2Bridge', new Select2Bridge($el))

window.initEditableBool = ->
  $(document).on 'click', '.js-auto-submit-checkbox', (e) ->
    $el = $(this)
    $el.attr('disabled', true)
    $wrap = $el.closest('.auto-submit-checkbox-wrap').removeClass('success', 'error')
    params = {}
    params[$el.attr('name')] = if $el.prop('checked') then 1 else 0
    params['_method'] = $el.data('method') || 'PATCH'
    $.ajax $el.data('url'),
      data: params
      method: 'POST'
      error: ->
        $wrap.addClass('error')
      success: ->
        $wrap.addClass('success')
        $el.attr('disabled', null)

window.initNestedFields = (opts={}) ->
  $(document).on 'nested:fieldAdded', 'form.simple_form', (e) =>
    window.locale_tabs?.initHandlers() unless opts.skip_tabs
    window.initFancySelect() unless opts.skip_fancy
    window.initPickers() unless opts.skip_pickers
    window.initEditor() unless opts.skip_editor
    opts.callback.call(e) if opts.callback

window.initCkeditor = (dom_id, options={}) ->
  if window.CKEDITOR
    CKEDITOR.replace(dom_id, options) unless CKEDITOR.instances[dom_id]
  else
    $.getScript $("##{dom_id}").data('cdnUrl'), ->
      CKEDITOR.replaceClass = null;
      CKEDITOR.replace(dom_id, options) unless CKEDITOR.instances[dom_id]

window.lazyInitCkeditor = (dom_id, options={}) ->
  $el = $("##{dom_id}")
  $form = $el.closest('form')
  height = options.height || 200
  height += if options.toolbar == 'mini' then 34 else 67
  $el.height(height)
  callback = (intersectionRatio) ->
    initCkeditor(dom_id, options) if intersectionRatio
  window.ckeditorVisibilityObserver = new IntersectionObserver (entries, observer) =>
    entries.forEach(((entry) => callback(entry.intersectionRatio)), {root: $form[0]})
  window.ckeditorVisibilityObserver.observe document.getElementById(dom_id)
