class window.Select2Bridge
  constructor: (@el) ->
    return if gon.test && !gon.enable_fancy_select
    @el.prop('required', null)
    @modal = $('#modal_form')
    @el.select2 @buildOptions()

  buildOptions: ->
    @options = @defaults()
    @options.multiple = @el.data('multi') unless _.isUndefined(@el.data('multi'))
    @options.width = @el[0].style.width || 'resolve'
    if @el.data('tags')
      @options.tokenSeparators = [',']
      @options.tags = @el.data('tags')
    else if @el.data('collection')
      @options.data = @el.data('collection')
    else if @el.data('class')
      @initAjaxInput()
    if @el.data('add')
      @initCreateChoiseOnce()
      @initCreateChoise()
    @options

  initCreateChoise: ->
    @options.createSearchChoice = (term, data) =>
      @el.siblings('.select2-create-choise').remove()
      @btn_add = $("<div class='btn btn-info btn-mini select2-create-choise'>#{I18n.t('admin_js.add')} - #{term}</div>")
      @btn_add.insertAfter @el
      @btn_add.click =>
        @modal.data('target', this)
        fn = =>
          $('#modal_form form input[name$="[name]"]').val(term)
          @modal.modal()
        $.get @el.data('add'), {modal: true}, fn, 'script'
      null

  initCreateChoiseOnce: ->
    return if Select2Bridge.initedCreateChoiseOnce
    @modal.on 'ajax:success', 'form', =>
      @modal.modal('hide')
      $el = @modal.data('target').el
      select2 = $el.data('select2')
      new_item = window.ab_admin_last_created
      if select2.opts.multiple
        data = $el.select2('data')
        data.push new_item
        $el.select2('data', data)
      else
        $el.select2('data', new_item)
      $el.siblings('.select2-create-choise').remove()
      $el.change()
    Select2Bridge.initedCreateChoiseOnce = true

  defaults: ->
    opts =
      formatNoMatches: ->
        I18n.t('admin_js.no_results')
      placeholder: ' '
      allowClear: true
      escapeMarkup: (m) -> m
    opts.minimumResultsForSearch = 10 unless gon.test
    opts

  initAjaxInput: ->
    if @el.data('image')
      @buildimageOptions()
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

  buildimageOptions: ->
    @options.formatResult = (item) ->
      html = '<div class="fancy_select-result">'
      html += "<img src='#{item.image}' alt='#{item.text}'>" if item.image
      html += "<span>#{item.text}</span></div>"
    @options.formatSelection = (item) ->
      html = '<div class="fancy_select-selection">'
      html += "<img src='#{item.image}' alt='#{item.text}'>" if item.image
      html += "<span>#{item.text}</span></div>"

  fetchAjaxParams: (term, page) =>
    cond = {}
    if @el.data('c')
      for kind in ['with', 'without']
        if @el.data('c')[kind]
          cond[kind] ||= {}
          for attr, id of @el.data('c')[kind]
            value = $('#' + id).val()
            cond[kind][attr] = value if value

      for kind in ['with_term', 'without_term']
        if @el.data('c')[kind]
          kind_key = kind.replace(/_term$/, '')
          cond[kind_key] ||= {}
          for attr, value of @el.data('c')[kind]
            cond[kind_key][attr] = value if value

      for kind in ['with_selector', 'without_selector']
        if @el.data('c')[kind]
          kind_key = kind.replace(/_selector$/, '')
          cond[kind_key] ||= {}
          for attr, value of @el.data('c')[kind]
            selectors = value.split(/\s+/)
            value = @el.closest(selectors[1] || 'html').find(selectors[0]).val()
            cond[kind_key][attr] = value if value

    data = {q: term, class: @el.data('class'), token: true, page: page}
    _.extend(data, cond)


#    $('#district_location_id').select2("data", {id: 123, text: '123'})
#    $el.change (data) ->
#      log data.val
#    createSearchChoice: (term) ->
#      log term
#      {id: 3, text: '123'}
