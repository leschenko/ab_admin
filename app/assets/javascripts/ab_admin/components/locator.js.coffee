class window.Locator
  constructor: ->
    @to_locale = $('#edit_locale_name').val()
    @from_locale = $('#main_locale_name').val()
    @button_html = "<button class='locator_translate btn btn-mini'>Translate</button>"
    $('#edit_locale .nested_inputs .block').append(@button_html)
    @initHandlers()
    @addAllButton()

  initHandlers: ->
    self = this
    $('#edit_locale button.locator_translate').click (e) ->
      e.preventDefault()
      $el = $(this)
      $cont = $el.closest('.nested_inputs')
      $input_to = $cont.find('textarea')
      input_from_id = $input_to.prop('id').replace(/^locale/, 'main')
      $input_from = $("##{input_from_id}")
      window.google_t($input_from.val(), $input_to, self.from_locale, self.to_locale)

  addAllButton: ->
    @all_button_html = "&nbsp;<button id='all_locator_translate' class='btn btn-mini btn-danger'>Translate all empty</button>"
    $('#edit_locale > div').append(@all_button_html)

    $('#all_locator_translate').click (e) ->
      e.preventDefault()
      empty_areas = _.filter $("#edit_locale textarea"), (el) ->
        not $.trim($(el).val())
      for el in empty_areas
        $(el).closest('.nested_inputs').find('.locator_translate').trigger('click')


