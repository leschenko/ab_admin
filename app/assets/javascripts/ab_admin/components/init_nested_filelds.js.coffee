window.initNestedFields = (opts={}) ->
  $form = $('form.simple_form:first')
  $form.bind 'nested:fieldAdded', (e) =>
    window.locale_tabs?.initHandlers() unless opts.skip_tabs
    window.initFancySelect() unless opts.skip_fancy
    opts.callback.call(e) if opts.callback