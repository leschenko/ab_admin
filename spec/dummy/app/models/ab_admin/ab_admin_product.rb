class AbAdminProduct < AbAdmin::AbstractResource
  #preview_path :product_path
  #preview_path { |product| product_path(product) }

  #actions :except => :index

  #settings :search => false, :batch => false

  #batch_action(:un_publish) { |item| item.un_publish! }
  #batch_action :destroy, false
  #batch_action :un_publish!, :confirm => 'Un Publish?'

  #action_item :destroy, false
  #action_item :only => :show do
  #  link_to 'Main page', '/', :class => 'btn'
  #end

  #resource_action_items :show, :edit
  #resource_action_item do
  #  link_to icon('arrow-down'), '/', :class => 'btn'
  #end

  #settings :comments => true
  settings :list_edit => true

  table do
    field :sku, :editable => true
    field(:picture) { |item| item_image_link(item) }
    field :name, :sortable => {:column => :id, :default_order => 'desc'}
    field :is_visible
    field :collection
    field :created_at
  end

  search do
    field :sku
    field :name
    field :is_visible
    field :collection, :fancy => true
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
    field :is_visible
    field :collection, :as => :association, :fancy => true
    locale_tabs do
      field :name
      field :description
    end
    #field :picture, :as => :uploader
    #field :map, :as => :map
  end

end
