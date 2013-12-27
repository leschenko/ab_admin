# Override Rails handling of confirmation

$.rails.allowAction = (element) ->
  # The message is something like "Are you sure?"
  message = element.data('confirm')
  # If there's no message, there's no data-confirm attribute,
  # which means there's nothing to confirm
  return true unless message
  # Clone the clicked element (probably a delete link) so we can use it in the dialog box.
  $link = element.clone()
    # We don't necessarily want the same styling as the original link/button.
    .removeAttr('class')
    # We don't want to pop up another confirmation (recursion)
    .removeAttr('data-confirm')
    # We want a button
    .addClass('btn').addClass('btn-danger')
    # We want it to sound confirmy
    .html(I18n.t('admin.js.confirm'))

  # Create the modal box with the message
  modal_html = """
               <div class="modal" id="confirmation_dialog">
                 <div class="modal-header">
                   <a class="close" data-dismiss="modal">×</a>
                   <h3>#{message}</h3>
                 </div>
                 <div class="modal-body">
                   <p></p>
                 </div>
                 <div class="modal-footer">
                   <a data-dismiss="modal" class="btn">#{I18n.t('admin.js.cancel')}</a>
                 </div>
               </div>
               """
  $modal_html = $(modal_html)
  # Add the new button to the modal box
  $modal_html.find('.modal-footer').append($link)
  # Pop it up
  $modal_html.modal()
  $link.click (e) ->
    e.preventDefault()
    $(this).closest('.modal').modal('hide')
    element.trigger('ajax:complete').trigger('confirm:success')
  # Prevent the original link from working
  return false