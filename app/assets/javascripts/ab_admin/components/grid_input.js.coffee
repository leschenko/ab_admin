class window.GridInput
  constructor: (el) ->
    @cont = $(el)
    @ids = @cont.data('val')
    @attr = @cont.data('attr')
    @active_css = 'active'
    @initHandlers()
    @initData()

  initHandlers: ->
    self = this
    @cont.on 'click', '.grid_input-item', (e) ->
      e.preventDefault()
      $el = $(this)
      $el.toggleClass(self.active_css)
      el_val = $el.data('id')
      active = $el.hasClass(self.active_css)
      if active
        self.ids.push(el_val)
      else
        self.ids = _.without(self.ids, el_val)
      $el.find('input').prop('checked', active)

    @cont.on 'click', '.grid_input-item input', (e) ->
      e.preventDefault()

    @cont.closest('form').submit(@serialize) if @attr

  initData: ->
    @cont.find("[data-id=#{id}]").click() for id in @ids

  serialize: =>
    @cont.children('input.grid_input-input').remove()
    @cont.prepend("<input class='grid_input-input' type='hidden' name='#{@attr}' value='#{id}'>") for id in @ids

$.fn.gridInput = ->
  @each ->
    $el = $(this)
    $el.data('GridInput') or $el.data('GridInput', new GridInput(this))
