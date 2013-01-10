class window.Pagination
  constructor: ->
    @from_bottom = 250
    @per_page = 8
    @refreshSource()
    @initHandlers()
    @initLoad()

  initHandlers: ->
    $(document).on 'pjax:end', @refreshSource

  initLoad: ->
    $(window).trigger "scroll" if $(window).height() <= $(document).height()

  refreshSource: =>
    @cont = $('#content')
    @url = window.location.href.replace(/page=\d+/, '')
    @page = 1
    @initScroll()

  initScroll: ->
    $(window).scroll @check

  check: =>
    @load() if @nearBottom()

  nearBottom: ->
    $(window).scrollTop() > $(document).height() - $(window).height() - @from_bottom

  load: ->
    @page++
    $(window).unbind 'scroll', @check
    $.ajax
      type: 'GET'
      url: @url
      data:
        page: @page
      success: @render
      dataType: 'script'
      complete: (xhr) => @render(xhr.responseText)

  render: (data) =>
    @cont.append(data)
    @initScroll() if $.trim(data)
