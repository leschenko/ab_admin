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
  settings history: {sidebar: true}, comments: true, list_edit: true

  belongs_to :collection

  permitted_params do
    [
        :name, :description, :is_visible, :price, :sku, :collection_id, :lat, :lon, :zoom, :token, :in_stock_at,
        *resource_class.all_translated_attribute_names
    ]
  end

  scope :un_visible
  scope :visible

  table do
    field :sku, default_order: true
    field(:picture) { |item| item_image_link(item) }
    field :name, sortable: {column: :id, default_order: 'desc'}, editable: true
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
    field :test do
      '<b>Capture block input</b>'.html_safe
    end
    field :picture, as: :uploader, edit_meta: true
    field :pictures, as: :uploader, edit_meta: true, crop: true, max_files: 2, min_size: 0.1
    field :attachment_files, as: :uploader, file_type: 'file'
    #field :pictures, as: :uploader, edit_meta: true, crop: true, max_files: 2, min_size: 0.1, max_size: 3
    #field :map, as: :map
  end

  show do
    field :sku
    field(:price) { |item| "$#{item.price}" }
  end
end


