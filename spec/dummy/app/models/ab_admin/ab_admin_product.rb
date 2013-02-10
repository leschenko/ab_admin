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

  settings :comments => true

  table do
    field :sku
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
    field :collection
    field :created_at
  end

  export do
    field :sku
    field :name
    field(:price) { "$#{price}" }
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
    field :collection, :as => :association
    locale_tabs do
      field :name
      field :description
    end
    field :picture, :as => :uploader
    field :map, :as => :map
  end

end

#class AbAdminProduct < AbAdmin::AbstractResource
#
#  index_view :table
#
#  batch_actions :destroy, :publish
#
#  scopes :visible, :published
#
#  preview :product_path
#
#  index_actions :edit, :show, :destroy
#
#  actions_on :edit => [:edit, :show, :destroy], :show => [:preview]
#
#  table do
#    field :id
#    field :sku
#    field :name, :sortable => false
#    image :picture
#    field :is_visible
#    field :created_at
#  end
#
#  grid do
#    title :name
#    image :picture
#    state :is_visible, :active => {:color => :green, :title => :published}, :inactive => {:color => :grey, :title => :un_published}
#  end
#
#  search do
#    field :id
#    field :sku
#    field :name
#    field :is_visible
#    field :created_at
#  end
#
#  form do
#    field :sku
#    field :name
#    field :description
#    group :publish, :if => :admin? do
#      field :is_visible
#    end
#    group :pictures do
#      field :picture
#    end
#    has_many :modifications do
#      field :sku
#      field :name
#      field :description
#    end
#  end
#
#  export do
#    field :id
#    field :sku
#    field :name
#    field :is_visible
#    field :created_at
#  end
#end
