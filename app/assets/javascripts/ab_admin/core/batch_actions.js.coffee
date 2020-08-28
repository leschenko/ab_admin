$ ->
  if $('#list')[0]
    input_name = 'q[id_in]'
    $(document).on 'click', '#list input.toggle', ->
      checked = $(this).is(":checked")
      $("#list [name='#{input_name}[]']").attr "checked", checked
      $('#list tbody tr').toggleClass('active_row', checked)
      $('#list').data('lastChecked', null) unless checked

    $(document).on 'click', '#list input.batch_check', (e) ->
      $el = $(this).closest('tr')
      $wrap = $('#list')
      if $el.hasClass('active_row')
        $wrap.data('lastChecked', null)
        $el.removeClass('active_row')
      else
        $el.addClass('active_row')
        if e.shiftKey && $wrap.data('lastChecked')
          $prev = $wrap.data('lastChecked')
          idx = [$prev.index(), $el.index()].sort()
          $items = $("#list > tbody > tr:eq(#{idx[0]})").nextUntil("#list > tbody > tr:eq(#{idx[1]})")
          $items.addClass('active_row')
          $items.find('> td:first input').attr('checked', true)
        $wrap.data('lastChecked', $el)

    batchIds = ->
      $("#list [name='#{input_name}[]']:checked").map(-> $(this).val()).get()

    idsInputs = ->
      inputs = ''
      for id in batchIds()
        inputs += "<input type='checkbox' name='#{input_name}[]' checked='1' value='#{id}' style='display:none;'/>"
      $(inputs)

    submitBatch = (el, $extraData = null) ->
      return unless batchIds().length
      $el = $(el)
      action = $el.data('action')
      $('#batch_action').val(action)
      $form = $('#batch_action_form')
      $idsInputs = idsInputs()
      $form.append($idsInputs)
      $form.append($extraData)
      $form.submit()
      $.fancybox.close()
      $extraData?.remove()
      $idsInputs.remove()

    $(document).on 'click', '#list > tbody > tr', (e) ->
      return true unless _.include(['TR', 'TD'], e.target.tagName)
      e.preventDefault()
      e.stopPropagation()
      $el = $(this)
      unless $(e.target).closest('#list > tbody > tr > td').hasClass('list_adds')
        $el.closest('tr').toggleClass('active_row')
        $el.find('td:first input').attr 'checked', (i, v) -> !v

    $(document).on 'click confirm:success', '.batch_action_link', (e) ->
      return unless batchIds().length
      e.preventDefault()
      $el = $(this)
      if $el.data('form')
        $form = $($el.data('form'))
        unless $form.find('.js-batch_form_submit').length
          $form.append("<div class='btn btn-primary js-batch_form_submit' data-form=#{$el.data('form')} data-action=#{$el.data('action')}><i class='icon-ok icon-white'></i></div>")
          $form.append("<div class='btn' onclick='$.fancybox.close()'><i class='icon-remove'></i></div>")
        $.fancybox($form)
      else
        submitBatch(this)

    $(document).on 'click', '.js-batch_form_submit', (e) ->
      e.preventDefault()
      submitBatch(this, $($(this).data('form')).find('input,textarea,select').clone())
