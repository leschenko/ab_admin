class window.Locator
  constructor: ->
    @to_locale = $('#edit_locale_name').val()
    @from_locale = $('#main_locale_name').val()
    @initHandlers()

  initHandlers: ->
    self = this

    $('#show_all').click ->
      $('#locale_data tr').show()

    $('#show_incomplete').click ->
      $('#locale_data tr').hide()
      $('#locale_data tr.error').show()

    $('#show_complete').click ->
      $('#locale_data tr').hide()
      $('#locale_data tr.ready').show()

    $('#translate_incomplete').click ->
      empty_areas = _.filter $("#locale_data tr textarea:enabled"), (el) ->
        not $.trim($(el).val())
      for el in empty_areas
        $(el).closest('tr').find('.auto_translate').trigger('click')

    $('#locale_data .auto_translate').click (e) ->
      e.preventDefault()
      $cont = $(this).closest('tr')
      $input_to = $cont.find('textarea:enabled')
      $input_from = $cont.find('textarea:disabled')
      window.google_t($input_from.val(), $input_to, self.from_locale, self.to_locale)

    $('.filter_field').change ->
      $el = $(this)
      ind = $el.closest('th').index() + 1
      text = $el.val().replace(/'/, '\'')
      $('#locale_data tr').hide()
      $("#locale_data td:nth-child(#{ind}):contains('#{text}')").parent().show()
