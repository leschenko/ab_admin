FactoryGirl.define do
  factory :structure do
    title 'Structure'
    is_visible true

    factory :structure_static_page do
      structure_type StructureType.static_page
      position_type PositionType.menu
    end

    factory :structure_main do
      title 'Main page'
      slug 'main-page'
      structure_type StructureType.main
      position_type PositionType.default
    end
  end
end
