Given /^structures tree exists:$/ do |table|
  @structures = table.hashes
  @structures.each do |attrs|
    parent = Structure.joins(:translations).where("structure_translations.title='#{attrs['parent_name']}'").first
    FactoryGirl.create(:structure_page, :title => attrs['title'], :parent => parent)
  end
end

Then /^I should see structures tree$/ do
  within 'ol.sortable_tree' do
    @structures.each do |attrs|
      page.should have_link(attrs['title'])
      if attrs['parent_name'].present?
        find_link(attrs['title']).first(:xpath, './/../../../../div/a', :text => attrs['parent_name']).should_not be_nil
      end
    end
  end
end

# buggy drug & drop in selenium
When /^I drag "(.*?)" to "(.*?)"$/ do |node_name, parent_name|
  node = first(:xpath, "//a[contains(., '#{node_name}')]/../i")
  parent = first(:xpath, "//a[contains(., '#{parent_name}')]/../../ol")
  node.drag_to(parent)
end