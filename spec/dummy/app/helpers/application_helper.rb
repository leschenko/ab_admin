module ApplicationHelper
  def admin_tree_item(item)
    render 'tree_item', :item => item, :child_tree => admin_tree(item.cached_children)
  end

  def admin_tree(items)
    return if items.blank?
    items.map{|item| admin_tree_item(item) }.join.html_safe
  end
end
