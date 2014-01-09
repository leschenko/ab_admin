window.toggleLoading = (is_loading=true) ->
  $('#loading').toggle(is_loading)

$ ->
  $(document).on 'click', '.pjax, .pagination a, .pjax_links a', (e) ->
    if e.which > 1 || e.metaKey || e.ctrlKey
      return
    else if $.support.pjax
      e.preventDefault()
      container = $(this).data('pjax-container')
      unless container
        table = $(this).closest('table.index_table:not(#list)')
        if table[0]
          container = "##{table.attr('id')}"
        else
          container = '[data-pjax-container]'

      main_pjax_wrap = container == '[data-pjax-container]'
      $.pjax
        container: container
        url: $(this).data('href') || $(this).attr('href')
        timeout: 50000
        push: main_pjax_wrap
        scrollTo: main_pjax_wrap
    else if $(this).data('href')
      e.preventDefault()
      window.location = $(this).data('href')

  unless fv.test
    $(document).on 'submit', '.pjax-form', (e) ->
      $el = $(this)
      if $.support.pjax
        e.preventDefault()
        $.pjax
          type: $el.attr('method')
          container: $el.data('pjax-container') || '[data-pjax-container]'
          url: this.action + (if (this.action.indexOf('?') != -1) then '&' else '?') + $el.serialize()
          timeout: 50000

  $(document)
    .on 'pjax:start', ->
      toggleLoading(true)
    .on 'pjax:end', ->
      toggleLoading(false)