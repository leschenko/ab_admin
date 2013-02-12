class window.ColumnsHider
  constructor: ->
    @store_key = 'cols'
    @data_el = $('#columns_hider_data')
    @column_names = @columnNames()
    @collection_name = $('html').attr('id').replace(/^controller_/, '')
    @data = @getData()
    @initDefaults()
    @initButtons()
    @initHandlers()
    @refreshColumns()

  initDefaults: ->
    @data

  setData: ->
    res = {}
    _.each @data, (v, k) ->
      res[k] = v.join('_')
    @storeData(res)

  getData: ->
    data = {}
    raw = $.parseJSON(@fetchData()) || {}
    _.each raw, (v, k) ->
      data[k] = []
      _.each v.split('_'), (el) ->
        data[k].push to_i(el) if el
    unless data[@collection_name]
      data[@collection_name] = []
      for col, i in @column_names
        data[@collection_name].push(i) if col.disabled
    data

  fetchData: ->
    window.localStorage?[@store_key] or $.cookie(@store_key)

  storeData: (data) ->
    str = JSON.stringify(data)
    if window.localStorage
      window.localStorage[@store_key] = str
    else
      $.cookie(@store_key, str, {path: '/'})

  initButtons: ->
    @data_el.empty()
    for col, i in @column_names
      css_class = if _.include(@data[@collection_name], i) then 'active' else ''
      html = "<button class='btn btn-primary #{css_class}' data-val='#{i}'>#{col.name}</button>"
      @data_el.append(html)

  columnNames: ->
    _.map $('#list th'), (el) ->
      $el = $(el)
      {disabled: $el.hasClass('hide_cell'), name: $.trim($el.text().replace(/[▼▲]/g, ''))}

  initHandlers: ->
    $('#submit_columns_hider').click =>
      col_ids = _.map $('#columns_hider_data .active'), (el) -> $(el).data('val')
      @data[@collection_name] = col_ids
      $('#columns_hider').modal('hide')
      @refreshColumns()
      @setData()
    $(document).on 'pjax:end', =>
      @refreshColumns()

  refreshColumns: ->
    if @data[@collection_name]
      @showAll()
      for i in @data[@collection_name]
        @hideByIndex(i + 1)

  hideByIndex: (i) ->
    $("#list tr th:nth-child(#{i}), #list tr td:nth-child(#{i})").hide()

  showAll: ->
    $("#list tr th, #list tr td").show()

$ ->
  window.columns_hider = new ColumnsHider()