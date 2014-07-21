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

  fetchData: ->
    window.localStorage?[@store_key] or $.cookie(@store_key)

  initButtons: ->
    @data_el.empty()
    for col, i in @column_names
      css_class = if _.include(@data[@collection_name], i) then 'active' else ''
      html = "<button class='btn btn-primary #{css_class}' data-val='#{i}'>#{col.name}</button>"
      @data_el.append(html)

  columnNames: ->
    _.map $('#list > thead > tr > th'), (el) ->
      $el = $(el)
      {disabled: $el.hasClass('hide_cell'), name: $.trim($el.text().replace(/[▼▲]/g, ''))}

  initHandlers: ->
    $('#submit_columns_hider').click =>
      col_ids = _.map $('#columns_hider_data .active'), (el) -> $(el).data('val')
      @data[@collection_name] = col_ids
      $('#columns_hider').modal('hide')
      @refreshColumns()
      @setData()
    $(document).on 'pjax:end admin:list_init', =>
      @refreshColumns()

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
  window.columns_hider = new ColumnsHider()