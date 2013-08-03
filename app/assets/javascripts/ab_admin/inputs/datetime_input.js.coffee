$ ->
  window.initPickers = ->
    base_options =
      format: "dd.mm.yyyy hh:ii"
      autoclose: true
      todayBtn: true
      language: I18n.locale

    search_options = _.defaults({pickerPosition: "bottom-left datetimepicker-bottom-left-custom"}, base_options)
    $('#search_form input.datepicker').datetimepicker search_options

    date_picker_options = _.defaults({format: "dd.mm.yyyy"}, base_options)
    $('.simple_form input.date_picker').datetimepicker date_picker_options

    $('.simple_form input.datetime_picker').datetimepicker base_options

    time_picker_options = _.defaults({format: "hh:ii"}, base_options)
    $('.simple_form input.time_picker').datetimepicker time_picker_options

  initPickers()
