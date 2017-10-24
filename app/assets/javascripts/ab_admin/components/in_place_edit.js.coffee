EditableForm = $.fn.editableform.Constructor
EditableForm.prototype.saveWithUrlHook = (value) ->
  originalUrl = @options.url
  @options.url = (params) =>
    if typeof originalUrl == 'function'
      originalUrl.call(@options.scope, params)
    else
      params[@options.model] ||= {}
      params[@options.model][params.name] = params.value
      params._method = 'PATCH'
      ajax_opts =
        url: originalUrl
        data: params
        type: 'POST'
        dataType: 'json'
      if @options.accept == 'script'
        ajax_opts.dataType = @options.accept
        ajaxOptions = $.extend(@options.ajaxOptions, {headers: {Accept: 'text/javascript, application/javascript'}})
      else
        ajaxOptions = @options.ajaxOptions
      delete params.name
      delete params.value
      delete params.pk
      $.ajax $.extend(ajax_opts, ajaxOptions)
  @saveWithoutUrlHook(value)
EditableForm.prototype.saveWithoutUrlHook = EditableForm.prototype.save
EditableForm.prototype.save = EditableForm.prototype.saveWithUrlHook

$(document).on 'admin:init', (e) ->
  $('.editable').editable
    onblur: 'submit'
    placement: 'bottom'
    emptytext: I18n.lookup('admin.js.empty') || 'Empty'
    error: (response, newValue) ->
      log response
      if response.status == 422
        flash JSON.parse(response.responseText).errors.join(', ')
      else
        response.responseText
    success: (response) ->
      if response && $(this).data().options?.accept == 'script'
        $.globalEval(response.responseText)
    datetimepicker:
      format: "dd.mm.yyyy hh:ii"
      autoclose: true
      todayBtn: true
      language: I18n.locale
    ajaxOptions:
      xhrFields:
        withCredentials: true
      headers:
        Accept: 'application/json'
$ ->
  _.each $('.editable'), (el) ->
    $el = $(el)
    return unless $el.data('type') == 'select2'
    options = new window.Select2Bridge($el, false).buildOptions()
    $el.data('select2', options)
