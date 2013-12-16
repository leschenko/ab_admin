#= require jquery-fileupload/basic

$ ->
  $('#fileupload_avatar').fileupload
    url: '/admin/assets'
    dataType: 'json',
    formData:
      assetable_type: 'User'
      assetable_id: 1
      method: 'avatar'
    done: (e, data) ->
      log [e, data]