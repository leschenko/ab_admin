$ ->
  if $('#search_form')[0]
    $('.predicate-select').change ->
      $el = $(this)
      $el.next('input').attr('name', "q[#{$el.val()}]")

    $("#search_form").submit ->
      $("#search_form [id$='_gteq']").val (i, v) ->
        v + " 00:00" if v
      $("#search_form [id$='_lteq']").val (i, v) ->
        v + " 23:59" if v

    $('#search_cancel').click (e) ->
      e.preventDefault()
      window.location.search = ""