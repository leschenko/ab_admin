#= require fileupload/vendor/jquery.ui.widget
#= require fileupload/jquery.iframe-transport
#= require fileupload/jquery.fileupload
#= require fileupload/jquery.fileupload-process
#= require fileupload/jquery.fileupload-validate
#= require ab_admin/components/base_assets

class window.AdminAssets extends BaseAssets
  showErrors: (e, data) ->
    errors = _.map(data.files,(file) ->
      [file.name, "<b>#{file.error}</b>"].join(' - ')).join('<br/>')
    bootbox.alert("<h3>#{errors}</h3>")

  initDisabled: ->
    super

  initHandlers: ->
    super
    @initEditMeta() if @options.edit_meta

  initEditMeta: ->
    @el.find('.fileupload-edit-button').show().click =>
      ids = @el.find('.fileupload-list .fileupload-asset').map(-> $(this).data('id')).get()
      unless ids[0]
        bootbox.alert 'Upload images first'
      $.get '/admin/assets/batch_edit', {ids: ids}, (data) =>
        bootbox.dialog(data, [
          {label: I18n.t('admin.js.cancel'), class: ' '},
          {label: I18n.t('admin.js.save'), class: 'btn-primary btn-large fileupload-edit-submit', callback: -> $('form.fileupload-edit-form').submit()}
        ], {animate: false})
        max_h = $(window).height() - 100
        $('.bootbox.modal').css
          height: max_h
          width: 900
          'margin-left': -450
        $('.modal-body').css
          'max-height': max_h - 90
