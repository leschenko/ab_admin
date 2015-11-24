class window.Select2Bridge
  constructor: (@el, init = true) ->
    return if fv.test && !fv.enable_fancy_select
    @el.prop('required', null)
    @modal = $('#modal_form')
    @el.select2(@buildOptions()) if init
    @initHandlers()
    @initSortable() if @el.data('sortable')

  initHandlers: ->
    @el.select2('container').on 'click', '.select2-choices a', (e) =>
      e.stopPropagation()
      $el = $(e.currentTarget)
      if $el.data('remote')
        e.preventDefault()
        @modal.data('target', this)
        fn = =>
          @runModal()
        $.get $el.attr('href'), {modal: true}, fn, 'script'

  buildOptions: ->
    @options = _.defaults(@el.data('select2_opts') || {},  @defaults())
    @options.multiple = @el.data('multi') unless _.isUndefined(@el.data('multi'))
    @options.width = @el[0].style.width || 'resolve'
    if @el.data('tags')
      @options.tokenSeparators = [',']
      @options.tags = @el.data('tags')
    if @el.data('data')
      data = @el.data('data')
      data = _.map(data, (el) -> {id: el, text: el.toString()} ) if data[0] && !_.isObject(data[0])
      @options.data = data
    else if @el.data('collection')
      @options.data = @el.data('collection')
    else if @el.data('class')
      @initAjaxInput()
    if @el.data('add')
      @initCreateChoiceOnce()
      @initCreateChoice()
    if @el.data('create-search-choice')
      @options.createSearchChoice = (term) ->
        log 'createSearchChoice'
        {id: term, text: term}
    @options

  runModal: ->
    @el.trigger('select2.modal_open')
    @modal.modal()

  initSortable: ->
    @el.select2('container').find('ul.select2-choices').sortable
      containment: 'parent'
      start: =>
        @el.select2 'onSortStart'
      update: =>
        @el.select2 'onSortEnd'

  initCreateChoice: ->
    @options.createSearchChoice = (term, data) =>
      @clearCreateChoice()
      @cont = @el.select2('container')
      @btn_add = $("<div class='btn btn-info btn-mini select2-create-choice'>#{I18n.t('admin.js.add')} - #{term}</div>")
      @btn_add.prependTo @cont
      @btn_add.click =>
        @modal.data('target', this)
        fn = =>
          $('#modal_form form input[name$="[name]"]').val(term)
          @runModal()
        $.get @el.data('add'), {modal: true}, fn, 'script'
      null

  initCreateChoiceOnce: ->
    return if Select2Bridge.initedCreateChoiceOnce
    @modal.on 'ajax:success', 'form', =>
      @modal.modal('hide')
      that = @modal.data('target')
      item = window.ab_admin_last_created || window.ab_admin_last_updated
      that.addItem(item)
      that.clearCreateChoice()
      @el.data("select2-change-triggered", true)
      @el.trigger('change', [item])
      @el.data("select2-change-triggered", false)
    Select2Bridge.initedCreateChoiceOnce = true

  addItem: (item) ->
    if @el.data('select2').opts.multiple
      data = _.reject(@el.select2('data'), (i) -> i.id == item.id)
      data.push item
      @el.select2('data', data)
    else
      @el.select2('data', item)

  clearCreateChoice: ->
    @el.select2('container').children('.select2-create-choice').remove()

  defaults: ->
    opts =
      formatNoMatches: ->
        I18n.t('admin.js.no_results')
      placeholder: ' '
      allowClear: true
      escapeMarkup: (m) -> m
    opts.minimumResultsForSearch = 10 unless fv.test || @el.data('add') || @el.data('create-search-choice')
    opts

  initAjaxInput: ->
    if @el.data('image')
      @buildImageOptions()
    if @el.data('result')
      @options.formatResult = (item) => fetchTemplate(@el.data('result'))(item)
    if @el.data('selection')
      @options.formatSelection = (item) => fetchTemplate(@el.data('selection'))(item)

    @options.initSelection = (el, callback) =>
      data = @el.data('pre')
      if @el.data('multi')
        data = @el.data('pre')
      else
        data = @el.data('pre')[0]
      callback(data)
    @options.ajax =
      url: '/admin/autocomplete',
      data: @fetchAjaxParams
      results: (data, page) ->
        results: data
        more: data.length > 0

  buildImageOptions: ->
    @options.formatResult = (item) ->
      html = '<div class="fancy_select-result">'
      html += "<img src='#{item.image}' alt='#{item.text}'>" if item.image
      if item.url
        html += "<a href='#{item.url}' target='_blank'>#{item.text}</a>"
      else
        html += "<span>#{item.text}</span>"
      html += "</div>"
    @options.formatSelection = (item) ->
      html = '<div class="fancy_select-selection">'
      html += "<img src='#{item.image}' alt='#{item.text}'>" if item.image
      if item.url
        html += "<a href='#{item.url}' target='_blank'>#{item.text}</a>"
      else
        html += "<span>#{item.text}</span>"

  fetchAjaxParams: (term, page) =>
    cond = {}
    condData = JSON.parse(@el.attr('data-c') || null)
    if condData
      for kind in ['with', 'without']
        if condData[kind]
          cond[kind] ||= {}
          for attr, id of condData[kind]
            value = $('#' + id).val()
            cond[kind][attr] = value if value

      for kind in ['with_term', 'without_term']
        if condData[kind]
          kind_key = kind.replace(/_term$/, '')
          cond[kind_key] ||= {}
          for attr, value of condData[kind]
            cond[kind_key][attr] = value if value

      for kind in ['with_selector', 'without_selector']
        if condData[kind]
          kind_key = kind.replace(/_selector$/, '')
          cond[kind_key] ||= {}
          for attr, value of condData[kind]
            selectors = value.split(/\s+/)
            value = @el.closest(selectors[1] || 'html').find(selectors[0]).val()
            cond[kind_key][attr] = value if value

    data =
      q: term
      class: @el.data('class')
      token: true
      page: page,
      order: @el.data('order')
      sort_mode: @el.data('sortMode')

    _.extend(data, cond)
