$ ->
  window.setInputDateTime = (field) ->
    date = $("##{field}_date").val()
    time = $("##{field}_time").val()
    $('#' + field).val("#{date} #{time}")

  window.initPickers = ->
    $('input.datepicker')
      .datepicker({format: 'dd.mm.yyyy', language: 'ru', autoclose: true})
      .on 'changeDate', (e) ->
        setInputDateTime($(e.target).data('target'))
      .on 'show', (e) ->
        if ($(document).width() - $(e.target).offset().left) < 200
          $('.datepicker.dropdown-menu:visible').css({left: "#{$(document).width() - 255}px"}).addClass('right_picker')
          
    $('input.timepicker').timepicker({showMeridian: false}).bind 'hidden', (e) ->
      setInputDateTime($(e.target).data('target'))

  initPickers()

  $('.simple_form').bind "nested:fieldAdded", =>
    initPickers()
    initFancySelect()