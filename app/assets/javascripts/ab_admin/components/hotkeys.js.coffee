window.initHotkeys = ->
  $(document).bind 'keydown.alt_n', -> $('a.new_resource:first').toHref()
  $(document).bind 'keydown.alt_left', -> $('a[rel^="prev"]:first').click()
  $(document).bind 'keydown.alt_right', -> $('a[rel="next"]:first').click()
  $(document).bind 'keydown.alt_s', -> $('#search_form').submit()
