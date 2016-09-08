class AbAdminCollection < AbAdmin::AbstractResource

  permitted_params :all

  table do
    field :name, sortable: false
    field :description, sortable: false
    field :is_visible
    field :products_count
    field :created_at
  end

  search do
    field :name
    field :description
    field :id
    field :is_visible
    field :products_count
    field :created_at
    field :updated_at
  end

  form do
    group :base do
      field :is_visible
      field :products_count
    end
    locale_tabs do
      field :name
      field :description, as: :editor
    end
    field :picture, as: :uploader, crop: true
    field :pictures, as: :uploader
    field :attachment_files, as: :uploader, file: true
  end
end