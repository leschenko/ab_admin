Then /^I should see attributes table:$/ do |table|
  within 'table' do
    table.rows_hash.each do |attr, value|
      expect(page).to have_content(attr)
      expect(page).to have_content(value)
    end
  end
end
