#= require ab_admin/core/utils
#= require ab_admin/core/ui_utils
#= require ab_admin/core/pjax
#= require ab_admin/core/confirmation
#= require ab_admin/core/batch_actions
#= require ab_admin/core/search_form
#= require ab_admin/core/pagination
#= require ab_admin/core/columns_hider
#= require ab_admin/core/view_layout

$ ->
  if $('#list')[0]
    window.viewType = 'list'
  else if $('form.simple_form')[0]
    window.viewType = 'form'

  $(document).on 'admin:init', (e) ->
    return unless window.viewType == 'list'
    clonePagination()

    $(document).trigger('admin:list_init')

    $('.per_page').click ->
      $.cookie('pp', $(this).data('val'))

    $('#list').on 'click', 'tr.list_edit .form_cancel', (e) ->
      e.preventDefault()
      $(this).closest('tr').remove()

  $(document).on 'admin:init', (e) ->
    return unless window.viewType == 'form'
    $form = $('form.simple_form')
    window.resource_id = $form.data('id')
    $form.trigger('admin:form_init')

  $(document).on 'admin:list_init', ->
    initPopover()
    initTooltip()

  $(document).on 'admin:form_init', 'form', (e) ->
    initEditor()
    initFancySelect()
    initPickers()

  $(document).on 'pjax:end', ->
    $(document).trigger({type: 'admin:init', pjax: true})
  $(document).trigger({type: 'admin:init'})

  $(document).on 'dblclick', '#list > tbody > tr', (e) ->
    e.preventDefault()
    unless $(e.target).closest('#list > tbody > tr > td').hasClass('list_adds')
      $(this).find('td a.resource_id_link').toHref()

  initFancySelect()
  initNestedFields()
  initNestedFields()
  inputSetToggle()
  inputBtnClose()

  if window.gon?.bg_color
    $('body').css('background-color', "##{window.gon.bg_color.replace(/^#/, '')}")

  initHotkeys() if window.gon?.hotkeys
