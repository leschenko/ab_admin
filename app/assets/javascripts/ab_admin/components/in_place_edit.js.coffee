EditableForm = $.fn.editableform.Constructor
EditableForm.prototype.saveWithUrlHook = (value) ->
  url = @options.url
  @options.url = (params) =>
    params[@options.model] ||= {}
    params[@options.model][params.name] = value
    ajax_opts =
      url: url
      data: params
      type: 'PUT'
      dataType: 'json'
    delete params.name
    delete params.value
    delete params.pk
    $.ajax $.extend(ajax_opts, @options.ajaxOptions)
  @saveWithoutUrlHook(value)
EditableForm.prototype.saveWithoutUrlHook = EditableForm.prototype.save
EditableForm.prototype.save = EditableForm.prototype.saveWithUrlHook

$(document).on 'admin:init', (e) ->
  return unless window.viewType == 'list'
  $('.editable').editable
    onblur: 'submit'
