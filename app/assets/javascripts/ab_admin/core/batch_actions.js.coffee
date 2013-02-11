$ ->
  if $('#list')[0]
    $("#list input.toggle").live "click", ->
      checked = $(this).is(":checked")
      $("#list [name='ids[]']").attr "checked", checked
      $('#list tbody tr').toggleClass('active_row', checked)

    $("#list tbody input").live "click", ->
      $(this).closest('tr').toggleClass('active_row')

    submitBatch = (el) ->
      if $("#list [name='ids[]']:checked")[0]
        $el = $(el)
        ids = $("#list [name='ids[]']:checked").map(-> $(this).val()).get()
        action = $el.data('action')
        $('#batch_action').val(action)
        $form = $('#batch_action_form')
        $form.append("<input type='checkbox' name='ids[]' checked='1' value='#{id}'/>") for id in ids
        $form.submit()

    $('#list tbody tr').live 'click', (e) ->
      return true unless _.include(['TR', 'TD'], e.target.tagName)
      e.preventDefault()
      e.stopPropagation()
      $el = $(this)
      $el.closest('tr').toggleClass('active_row')
      $el.find('td:first input').attr 'checked', (i, v) -> !v

    $('.batch_action_link').live
      click: (e) ->
        e.preventDefault()
        submitBatch(this)
      'confirm:success': ->
        submitBatch(this)
