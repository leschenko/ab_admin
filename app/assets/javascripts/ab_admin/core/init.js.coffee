#= require ab_admin/core/utils
#= require ab_admin/core/ui_utils
#= require ab_admin/core/pjax
#= require ab_admin/core/confirmation
#= require ab_admin/core/batch_actions
#= require ab_admin/core/search_form
#= require ab_admin/core/pagination
#= require ab_admin/core/columns_hider

$ ->
  if $('#list')[0]
    window.viewType = 'list'
  else if $('form.simple_form')[0]
    window.viewType = 'form'

  $(document).on 'admin:init', (e) ->
    return unless window.viewType == 'list'
    clonePagination()
    initPopover()
    initTooltip()

    $('.per_page').click ->
      $.cookie('pp', $(this).data('val'))

    $('#list').on 'click', '.form_cancel', (e) ->
      e.preventDefault()
      $(this).closest('tr').remove()


  $(document).on 'admin:init', (e) ->
    return unless window.viewType == 'form'
    window.resource_id = $('form.simple_form').data('id')
    $(document).trigger('admin:form_init')


  $(document).on 'admin:form_init', 'form', (e) ->
    focusInput($(this))
    initEditor()
    initFancySelect()
    inputSetToggle()

  $(document).on 'pjax:end', ->
    $(document).trigger({type: 'admin:init', pjax: true})
  $(document).trigger({type: 'admin:init'})

  $(document).on 'dblclick', '#list tbody tr', (e) ->
    e.preventDefault()
    $el = $(this)
    $el.find('td a.resource_id_link').click()


  initFancySelect()
  #  initAcFileds()
  if window.gon?.bg_color
    $('body').css('background-color', "##{window.gon.bg_color.replace(/^#/, '')}")

  if window.gon?.hotkeys
    $(document).bind 'keydown.alt_n', -> $('a.new_resource:first').click()
    $(document).bind 'keydown.alt_left', -> $('a[rel^="prev"]:first').click()
    $(document).bind 'keydown.alt_right', -> $('a[rel="next"]:first').click()
    $(document).bind 'keydown.alt_s', -> $('#search_form').submit()

#    $('form .region_ac').regionAc()
#    new NestedFieldsAdder
#      region_ac: true
#      callback: ->
#        initPickers()
#        initFancySelect()
#        initEditor()
