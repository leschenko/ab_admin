#$ ->
#  window.setInputDateTime = (field) ->
#    date = $("##{field}_date").val()
#    time = $("##{field}_time").val()
#    $('#' + field).val("#{date} #{time}")
#
#  window.initPickers = ->
#    $('input.datepicker')
#      .datepicker({format: 'dd.mm.yyyy', language: 'ru', autoclose: true})
#      .on 'changeDate', (e) ->
#        setInputDateTime($(e.target).data('target'))
#      .on 'show', (e) ->
#        if ($(document).width() - $(e.target).offset().left) < 200
#          $('.datepicker.dropdown-menu:visible').css({left: "#{$(document).width() - 255}px"}).addClass('right_picker')
#
#    $('input.timepicker').timepicker({showMeridian: false}).bind 'hidden', (e) ->
#      setInputDateTime($(e.target).data('target'))
#
#  initPickers()
#
#  $('.simple_form').bind "nested:fieldAdded", =>
#    initPickers()

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
