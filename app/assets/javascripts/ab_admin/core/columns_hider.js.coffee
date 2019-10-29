class window.ColumnsHider
  constructor: ->
    @store_key = 'cols'
    @wrap = $('#columns_hider_wrap')
    @menu = @wrap.find('.dropdown-menu')
    @column_names = @columnNames()
    @collection_name = window.location.href.match(/admin\/(\w+)/)?[1]
    return unless @collection_name
    @data = @getData()
    @initButtons()
    @initHandlers()
    @refreshColumns()

  initHandlers: ->
    @menu.on 'click', 'label', (e) =>
      e.preventDefault()
      e.stopPropagation()
      $input = $(e.currentTarget).find('input')
      $input.prop('checked', !$input.is(':checked'))
      colIds = _.map @menu.find('input:not(:checked)'), (el) -> parseInt($(el).val())
      @data[@collection_name] = colIds
      @refreshColumns()
      @setData()

    $(document).on 'pjax:end admin:list_init', =>
      @refreshColumns()

  initButtons: ->
    log @data[@collection_name]
    @menu.empty()
    for col, i in @column_names
      isActive = !_.include(@data[@collection_name], i)
      html = "<label class='checkbox'><input type='checkbox' #{'checked' if isActive} value='#{i}'>#{col.name}</label>"
      @menu.append(html)

  setData: ->
    res = {}
    _.each @data, (v, k) ->
      res[k] = v.join('_')
    window.storeData(@store_key, res)

  getData: ->
    data = {}
    raw = $.parseJSON(window.fetchData(@store_key)) || {}
    _.each raw, (v, k) ->
      data[k] = []
      _.each v.split('_'), (el) ->
        data[k].push to_i(el) if el
    unless data[@collection_name]
      data[@collection_name] = []
      for col, i in @column_names
        data[@collection_name].push(i) if col.disabled
    data

  columnNames: ->
    _.map $('#list > thead > tr > th'), (el) ->
      $el = $(el)
      {disabled: $el.hasClass('hide_cell'), name: $.trim($el.text().replace(/[▼▲]/g, '')) || ' - '}

  refreshColumns: ->
    if @data[@collection_name]
      @showAll()
      for i in @data[@collection_name]
        @hideByIndex(i + 1)
      $(document).trigger('admin:refresh_columns')

  hideByIndex: (i) ->
    $("#list > thead > tr > th:nth-child(#{i}), #list > tbody > tr > td:nth-child(#{i})").hide()

  showAll: ->
    $("#list > thead > tr > th, #list > tbody > tr > td").show()

$ ->
  window.columnsHider = new ColumnsHider()
