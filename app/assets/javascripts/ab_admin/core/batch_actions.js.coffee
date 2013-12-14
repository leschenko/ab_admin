$ ->
  if $('#list')[0]
    input_name = 'by_ids'
    $(document).on 'click', '#list input.toggle', ->
      checked = $(this).is(":checked")
      $("#list [name='#{input_name}[]']").attr "checked", checked
      $('#list tbody tr').toggleClass('active_row', checked)

    $(document).on 'click', '#list input.batch_check', ->
      $(this).closest('tr').toggleClass('active_row')

    submitBatch = (el) ->
      if $("#list [name='#{input_name}[]']:checked")[0]
        $el = $(el)
        ids = $("#list [name='#{input_name}[]']:checked").map(-> $(this).val()).get()
        action = $el.data('action')
        $('#batch_action').val(action)
        $form = $('#batch_action_form')
        $form.append("<input type='checkbox' name='#{input_name}[]' checked='1' value='#{id}' style='display:none;'/>") for id in ids
        $form.submit()

    $(document).on 'click', '#list > tbody > tr', (e) ->
      return true unless _.include(['TR', 'TD'], e.target.tagName)
      e.preventDefault()
      e.stopPropagation()
      $el = $(this)
      unless $(e.target).closest('#list > tbody > tr > td').hasClass('list_adds')
        $el.closest('tr').toggleClass('active_row')
        $el.find('td:first input').attr 'checked', (i, v) -> !v

    $(document).on 'click confirm:success', '.batch_action_link', (e) ->
      e.preventDefault()
      submitBatch(this)
