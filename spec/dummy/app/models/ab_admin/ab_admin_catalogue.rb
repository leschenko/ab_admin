class AbAdminCatalogue < AbAdmin::AbstractResource

  settings index_views: %i(tree table), search: false, batch: false, well: false

  # permitted_params :name, :parent
  permitted_params do
    if admin?
      [:name, :parent]
    else
      []
    end
  end
end
