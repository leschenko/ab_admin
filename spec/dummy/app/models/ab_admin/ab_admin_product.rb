class AbAdminProduct < AbAdmin::AbstractResource
  table do
    field :sku
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
    field :is_visible
    field :collection
    field :created_at
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
