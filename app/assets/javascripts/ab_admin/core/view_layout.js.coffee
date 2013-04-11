class window.ViewLayout
  constructor: ->
    @wrap = $('#main')
    @control = $('#view_layout')
    @sidebar_on = $('#toggle_sidebar_on')
    @sidebar_off = $('#toggle_sidebar_off')
    @css_classes = @control.find('.btn').map(-> $(this).data('css')).get().join(' ')
    @restoreMainCss()
    @initHandlers()

  initHandlers: ->
    self = this
    $('#toggle_sidebar_off').click =>
      @wrap.addClass('hide_sidebar')
      @storeMainCss()

    $('#toggle_sidebar_on').click =>
      @wrap.removeClass('hide_sidebar')
      @storeMainCss()

    $('#view_layout').on 'click', '.btn', ->
      $el = $(this)
      $el.toggleClass('active').siblings().removeClass('active')
      self.wrap.removeClass(self.css_classes).toggleClass($el.data('css'), $el.hasClass('active'))
      self.storeMainCss()

  storeMainCss: ->
    storeData('view_layout', @wrap.prop('className'))

  restoreMainCss: ->
    css = fetchData('view_layout')
    if css
      @wrap.prop('className', css)
      @control.find("[data-css='#{css_class}']").addClass('active') for css_class in css.split(' ')

$ ->
  if $('#list')[0]
    window.view_layout = new ViewLayout()