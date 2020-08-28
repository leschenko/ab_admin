Given /^catalogues tree exists:$/ do |table|
  @tree = table.hashes
  @tree.each do |attrs|
    parent = Catalogue.where(name: attrs['parent_name']).first
    FactoryBot.create(:catalogue, name: attrs['title'], parent: parent)
  end
end

Then /^I should see \w+ tree$/ do
  within 'ol.sortable_tree' do
    @tree.each do |attrs|
      expect(page).to have_link(attrs['title'])
      if attrs['parent_name'].present?
        parent_a = find_link(attrs['title']).first(:xpath, './/../../../../div/a', text: attrs['parent_name'])
        expect(parent_a).not_to be_nil
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
