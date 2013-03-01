window.initNestedFields = (opts={}) ->
  $(document).on 'nested:fieldAdded', 'form.simple_form', (e) =>
    window.locale_tabs?.initHandlers() unless opts.skip_tabs
    window.initFancySelect() unless opts.skip_fancy
    window.initPickers() unless opts.skip_pickers
    opts.callback.call(e) if opts.callback