class window.SortableTree
  constructor: (@cont) ->
    @url = @cont.data('url')
    @max_levels = @cont.data('max_levels')
    @initTree()

  initTree: ->
    @cont.nestedSortable
      items: 'li'
      helper: 'clone'
      handle: 'i.icon-move'
      tolerance: 'pointer'
      maxLevels: @max_levels
      revert: 250
      tabSize: 25
      opacity: 0.6
      placeholder: 'placeholder'
      disableNesting: 'no-nest'
      toleranceElement: '> div'
      forcePlaceholderSize: true

    @cont.on 'sortupdate', (event, ui) =>
      item = ui.item
      item_id = item.data('id')
      prev_id = item.prev().data('id')
      next_id = item.next().data('id')
      parent_id = item.parent().parent().data('id')

      @rebuild(item_id, parent_id, prev_id, next_id)

  rebuild: (item_id, parent_id, prev_id, next_id) =>
    $.ajax
      type: 'POST'
      dataType: 'script'
      url: @url
      data:
        id: item_id
        parent_id: parent_id
        prev_id: prev_id
        next_id: next_id

      beforeSend: (xhr) ->
        $('.sortable_tree i.handle').hide()

      success: (data, status, xhr) ->
        $('.sortable_tree i.handle').show()

      error: (xhr, status, error) ->
        log error

$.fn.sortableTree = ->
  @each ->
    $el = $(this)
    $el.data('sortableTree') or $el.data('sortableTree', new SortableTree($el))
