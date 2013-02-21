# encoding: utf-8
FactoryGirl.define do
  factory :structure_page, class: Structure do
    title 'Structure'
    structure_type StructureType.static_page
    position_type PositionType.menu
    is_visible true
  end

  factory :structure_main, class: Structure do
    title 'Main page'
    slug 'main-page'
    structure_type StructureType.main
    position_type PositionType.default
    is_visible true
  end
end
