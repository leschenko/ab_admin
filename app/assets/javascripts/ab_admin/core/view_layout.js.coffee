class window.ViewLayout
  constructor: ->
    @wrap = $('#main')
    @initElements()
    @css_classes = @control.find('.btn').map(-> $(this).data('css')).get().join(' ')
    @initHandlers()
    @restoreMainCss(true)
    $(document).on 'pjax:end', =>
      @initElements()
      @restoreMainCss()

  initElements: ->
    @control = $('#view_layout')
    @sidebar_on = $('#toggle_sidebar_on')
    @sidebar_off = $('#toggle_sidebar_off')

  initHandlers: ->
    self = this
    $(document).on 'click', '#toggle_sidebar_off', =>
      @wrap.addClass('hide_sidebar')
      @storeMainCss()

    $(document).on 'click', '#toggle_sidebar_on', =>
      @wrap.removeClass('hide_sidebar')
      @storeMainCss()

    $(document).on 'click', '#view_layout .btn', ->
      $el = $(this)
      $el.toggleClass('active').siblings().removeClass('active')
      self.wrap.removeClass(self.css_classes).toggleClass($el.data('css'), $el.hasClass('active'))
      self.storeMainCss()

  storeMainCss: ->
    storeData('view_layout', @wrap.prop('className'))

  restoreMainCss: (wrap=false) =>
    css = fetchData('view_layout')
    if css
      log css
      @wrap.prop('className', css) if wrap
      @control.find("[data-css='#{css_class}']").addClass('active') for css_class in css.split(' ')

$ ->
  if $('#list')[0]
    window.view_layout = new ViewLayout()