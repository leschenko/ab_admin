class AddLatLonZoomToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :lat, :float
    add_column :products, :lon, :float
    add_column :products, :zoom, :integer, default: 14
  end
end
