$ ->
  $(document).on 'click', 'form a.add_nested_fields', ->
    $el = $(this)
    assoc = $el.attr("data-association")
    content = $("#" + assoc + "_fields_blueprint").html()
    context = ($el.closest('.fields').closestChild('input:not([id$="_destroy"]), textarea, select').eq(0).attr('name') || '').replace(new RegExp('\[[a-z_]+\]$'), '')
    if context
      parent_names = context.match(/[a-z_]+_attributes/g) or []
      parent_ids = context.match(/[0-9]+/g) or []
      i = 0

      while i < parent_names.length
        if parent_ids[i]
          content = content.replace(new RegExp("(_" + parent_names[i] + ")_.+?_", "g"), "$1_" + parent_ids[i] + "_")
          content = content.replace(new RegExp("(\\[" + parent_names[i] + "\\])\\[.+?\\]", "g"), "$1[" + parent_ids[i] + "]")
        i++
    regexp = new RegExp("new_" + assoc, "g")
    new_id = (new Date().getTime()).toString().substr(-10, 10)
    content = content.replace(regexp, new_id)

    guid = $(content).find('[name$="[fileupload_guid]"]').val()
    content = content.replace(new RegExp(guid, 'g'), new_id) if guid
    $content = $(content)

    if $el.data('params')
      for k, v of $el.data('params')
        $content.find("[name$='[#{k}]']").val(v)

    if $el.data('container')
      $cont = $($el.data('container'))
      field = $content.prependTo($cont)
    else
      $cont = $el
      field = $content.insertBefore($cont)

    $el.closest("form").trigger
      type: "nested:fieldAdded"
      field: field
      new_id: new_id

    false

  $(document).on 'click', 'form a.remove_nested_fields', ->
    hidden_field = $(this).prev("input[type=hidden]")[0]
    hidden_field.value = "1" if hidden_field
    $fields = $(this).closest(".fields")
    if $fields.find('input[type="hidden"]:last').prop('name')?.match(/\[id\]/)
      $fields.hide()
    else
      $fields.remove()

    $(this).closest("form").trigger "nested:fieldRemoved"
    false


$.fn.closestChild = (selector) ->
  # breadth first search for the first matched node
  if selector and selector isnt ""
    queue = []
    queue.push this
    while queue.length > 0
      node = queue.shift()
      children = node.children()
      i = 0

      while i < children.length
        child = $(children[i])
        return child  if child.is(selector) #well, we found one
        queue.push child
        ++i
  $() #nothing found