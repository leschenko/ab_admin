$ ->
  if $('#list')[0]
    window.viewType = 'list'
  else if $('form.simple_form')[0]
    window.viewType = 'form'
  $(document).trigger('admin:init', {view: window.viewType})

  $(document).on 'admin:init', (e) ->
    return unless if e.viewType == 'list'
    clonePagination()
    initPopover()
    initTooltip()

    $('#list tbody tr').dblclick (e) ->
      e.preventDefault()
      $el = $(this)
      window.location.href = $el.find('td a.resource_id_link').prop('href')

    $('.per_page').click ->
      $.cookie('pp', $(this).data('val'))


  $(document).on 'admin:init', (e) ->
    return unless e.viewType == 'form'
    $('form .region_ac').regionAc()
    initEditor()
    inputSetToggle()

    new NestedFieldsAdder
      region_ac: true
      callback: ->
        initPickers()
        initChosen()
        initEditor()


  $(document).on 'pjax:end', ->
    $(document).trigger('admin:init', {view: window.viewType, pjax: true})


  initChosen()
  #  initAcFileds()
  if window.gon?.bg_color
    $('body').css('background-color', "##{window.gon.bg_color.replace(/^#/, '')}")
