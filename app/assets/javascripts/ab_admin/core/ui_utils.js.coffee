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

window.flash = (message, type='notice') ->
  $('#container').prepend $("<div class='alert alert-#{type}'><a class='close' data-dismiss='alert'>×</a>#{message}</div>")

window.focusInput = (scope=null) ->
  scope ||= $('form.simple_form:first')
  $('input[type="text"],input[type="string"],select:visible,textarea:visible').not('.fancy_select,.datepicker').get(0)?.focus()

window.templateStorage = {}
window.fetchTemplate = (tmpl_id) ->
  window.templateStorage[tmpl_id] ||= Handlebars.compile($(tmpl_id).html())

window.initFancySelect = ->
  return if gon.test
  defaults =
    formatNoMatches: ->
      I18n.t('admin_js.no_results')
    placeholder: ' '
    allowClear: true
    minimumResultsForSearch: 10

  $('form .fancy_select, form input.token, .without_form.fancy_select').each ->
    $el = $(this)
    return if $el.data('select2')
    options = _.defaults({}, defaults)
    options.multiple = $el.data('multi') unless _.isUndefined($el.data('multi'))
    options.width = $el[0].style.width || 'resolve'
    if $el.data('tags')
      options.tokenSeparators = [","]
      options.tags = $el.data('tags')
    else if $el.data('class')
      if $el.data('image')
        options.formatResult = (item) ->
          html = '<div class="fancy_select-result">'
          html += "<img src='#{item.image}' alt='#{item.text}'>" if item.image
          html += "<span>#{item.text}</span></div>"
        options.formatSelection = (item) ->
          html = '<div class="fancy_select-selection">'
          html += "<img src='#{item.image}' alt='#{item.text}'>" if item.image
          html += "<span>#{item.text}</span></div>"
      if $el.data('result')
        options.formatResult = (item) -> fetchTemplate($el.data('result'))(item)
      if $el.data('selection')
        options.formatSelection = (item) -> fetchTemplate($el.data('selection'))(item)

      if $el.data('image') || $el.data('result') || $el.data('selection')
        options.escapeMarkup = (m) -> m

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
                kind_key = kind.replace(/_term$/, '')
                cond[kind_key] ||= {}
                for attr, value of $el.data('c')[kind]
                  cond[kind_key][attr] = value

          data = {q: term, class: $el.data('class'), token: true}
          _.extend(data, cond)

        results: (data, page) ->
          results: data

    $el.select2(options)

#    $('#district_location_id').select2("data", {id: 123, text: '123'})
#    $el.change (data) ->
#      log data.val
#    createSearchChoice: (term) ->
#      log term
#      {id: 3, text: '123'}
