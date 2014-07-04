EditableForm = $.fn.editableform.Constructor
EditableForm.prototype.saveWithUrlHook = (value) ->
  url = @options.url
  @options.url = (params) =>
    params[@options.model] ||= {}
    params[@options.model][params.name] = value
    params._method = 'PATCH'
    ajax_opts =
      url: url
      data: params
      type: 'POST'
      dataType: 'json'
    delete params.name
    delete params.value
    delete params.pk
    $.ajax $.extend(ajax_opts, @options.ajaxOptions)
  @saveWithoutUrlHook(value)
EditableForm.prototype.saveWithoutUrlHook = EditableForm.prototype.save
EditableForm.prototype.save = EditableForm.prototype.saveWithUrlHook

$(document).on 'admin:init', (e) ->
  $('.editable').editable
    onblur: 'submit'
    placement: 'bottom'
    emptytext: I18n.lookup('admin.js.empty') || 'Empty'
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
