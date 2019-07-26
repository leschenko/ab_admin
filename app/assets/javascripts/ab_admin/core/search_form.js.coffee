$ ->
  if $('#search_form')[0]
    $('.predicate-select').change ->
      $el = $(this)
      $el.next('input').attr('name', "q[#{$el.val()}]")

    $('.js-search-cancel').click (e) ->
      e.preventDefault()
      window.location.search = ""