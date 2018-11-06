$ ->
  window.initPickers = ->
    base_options =
      format: "yyyy-mm-dd hh:ii"
      autoclose: true
      todayBtn: true
      viewSelect: 'month'
      minView: 'day'
      language: I18n.locale

    search_form_options = _.defaults({pickerPosition: "bottom-left datetimepicker-bottom-left-custom"}, base_options)
    search_form_options_gt = _.defaults({initialDate: new Date(new Date().setHours(0,0,0,0))}, search_form_options)
    search_form_options_lt = _.defaults({initialDate: new Date(new Date().setHours(23,59,59,999))}, search_form_options)
    $('#search_form input.datepicker[name*="_at_gteq]"]').datetimepicker search_form_options_gt
    $('#search_form input.datepicker[name*="_at_lteq]"]').datetimepicker search_form_options_lt

    date_picker_options = _.defaults({format: "yyyy-mm-dd", minView: 2}, base_options)
    $('.simple_form input.date_picker').datetimepicker date_picker_options

    $('.simple_form input.datetime_picker').datetimepicker base_options

    time_picker_options = _.defaults({format: "hh:ii"}, base_options)
    $('.simple_form input.time_picker').datetimepicker time_picker_options

  initPickers()
