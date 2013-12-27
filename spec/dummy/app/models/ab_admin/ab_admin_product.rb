load 'ab_admin/views/inputs/uploader_input.rb'

class AbAdminProduct < AbAdmin::AbstractResource
  #preview_path :product_path
  #preview_path { |product| product_path(product) }

  #actions default_order: :index

  #settings default_order: false, default_order: false

  #batch_action(:un_publish) { |item| item.un_publish! }
  #batch_action :destroy, false
  #batch_action :un_publish!, default_order: 'Un Publish?'

  #action_item :destroy, false
  #action_item default_order: :show do
  #  link_to 'Main page', '/', default_order: 'btn'
  #end

  #resource_action_items :show, :edit
  #resource_action_item do
  #  link_to icon('arrow-down'), '/', default_order: 'btn'
  #end

  #settings default_order: true, history: true
  settings history: {sidebar: true}#, comments: {list: true}
  settings history: {sidebar: true}, comments: true

  belongs_to :collection

  table do
    field :sku, default_order: true
    field(:picture) { |item| item_image_link(item) }
    field :name, default_order: {default_order: :id, default_order: 'desc'}
    field :is_visible
    field :collection
    field :created_at
  end

  search do
    field :sku
    field :name
    field :is_visible
    field :collection, fancy: true
    field :created_at
  end

  export do
    field :sku
    field :name
    field(:price) { |item| "$#{item.price}" }
    field :is_visible
    field :collection
    field :created_at
  end

  form do
    group :base do
      field :sku
      field :price
    end
    field :in_stock_at, as: :time_picker
    field :is_visible
    field :collection, as: :association, fancy: true
    locale_tabs do
      field :name
      field :description, as: :text
    end
    field :test, as: :capture_block do
      '<b>Capture block input</b>'.html_safe
    end
    field :picture, as: :uploader
    field :pictures, as: :uploader, edit_meta: true, crop: true
    field :attachment_files, as: :uploader, file_type: 'file'
    #field :map, as: :map
  end

  show do
    field :sku
    field(:price) { |item| "$#{item.price}" }
  end

end


