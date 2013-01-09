class window.AdminComments
  constructor: ->
    @template = Handlebars.compile($("#comment_template").html())
    @container = $('#admin_comments')
    @form = $('#new_admin_comment')
    @initHandlers()

  initHandlers: ->
    $('#submit_admin_comments_form').click (e) =>
      e.preventDefault()
      if @form[0].checkValidity()
        $.post @form.attr('action'), @form.serialize(), ((data) =>
          $('#product_is_notify').prop('checked', true)
          @render(data)), 'json'

    $('.del_admin_comment').live 'click', ->
      $(@).closest('.admin_comment').hide()

  render: (comment) ->
    @container.append(@template(comment))
    @form[0].reset()

