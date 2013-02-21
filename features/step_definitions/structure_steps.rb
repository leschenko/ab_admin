Given /^structures tree exists:$/ do |table|
  @tree = table.hashes
  @tree.each do |attrs|
    parent = Structure.joins(:translations).where("structure_translations.title='#{attrs['parent_name']}'").first
    FactoryGirl.create(:structure_page, title: attrs['title'], parent: parent)
  end
end
