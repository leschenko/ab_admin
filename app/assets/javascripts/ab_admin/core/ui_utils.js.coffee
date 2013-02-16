window.clonePagination = ->
  $('.pagination:first').clone().appendTo($('.batch_actions'))

window.initPopover = ->
  $('.popover').hide()
  $('a[rel=popover]').popover({trigger: 'hover'})

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

window.focusInput = (scope=null) ->
  $('input[type="text"],input[type="string"],select:visible,textarea:visible', scope || $('form.simple_form:first')).get(0)?.focus()

window.initFancySelect = ->
  return if gon.test
  defaults =
    formatNoMatches: ->
      I18n.t('admin_js.no_results')
    placeholder: ' '
    allowClear: true

  $('form .fancy_select, form input.token, .without_form.fancy_select').each ->
    $el = $(this)
    options = _.defaults({multiple: $el.data('multi')}, defaults)
    options.width = $el[0].style.width || 'resolve'
    if $el.data('class')
      options.initSelection = (el, callback) ->
        data = $el.data('pre')
        if $el.data('multi')
          data = $el.data('pre')
        else
          data = $el.data('pre')[0]
        callback(data)
      options.ajax =
        url: "/admin/autocomplete",
        data: (term, page) ->
          cond = {}
          if $el.data('c')
            for kind in ['with', 'without']
              if $el.data('c')[kind]
                cond[kind] ||= {}
                for attr, id of $el.data('c')[kind]
                  cond[kind][attr] = $('#' + id).val()

            for kind in ['with_term', 'without_term']
              if $el.data('c')[kind]
                cond[kind] ||= {}
                for attr, value of $el.data('c')[kind]
                  cond[kind][attr] = value

          data = {q: term, class: $el.data('class'), token: true}
          _.extend(data, cond)

        results: (data, page) ->
          results: data

    $el.select2(options)
