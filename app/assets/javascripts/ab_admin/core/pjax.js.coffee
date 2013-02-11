$ ->
  $('.pjax, .pagination a, .pjax_links a').live 'click', (event) ->
    if event.which > 1 || event.metaKey || event.ctrlKey
      return
    else if $.support.pjax
      event.preventDefault()
      $.pjax
        container: $(this).data('pjax-container') || '[data-pjax-container]'
        url: $(this).data('href') || $(this).attr('href')
        timeout: 50000
    else if $(this).data('href')
      event.preventDefault()
      window.location = $(this).data('href')

  unless gon.test
    $('.pjax-form').live 'submit', (event) ->
      $el = $(this)
      if $.support.pjax
        event.preventDefault()
        $.pjax
          type: $el.attr('method')
          container: $el.data('pjax-container') || '[data-pjax-container]'
          url: this.action + (if (this.action.indexOf('?') != -1) then '&' else '?') + $el.serialize()
          timeout: 50000

  $(document)
    .on 'pjax:start', ->
      $('#loading').show()
    .on 'pjax:end', ->
      $('#loading').hide()