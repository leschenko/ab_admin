Then /^I should see attributes table:$/ do |table|
  within 'table' do
    table.rows_hash.each do |attr, value|
      page.should have_content(attr)
      page.should have_content(value)
    end
  end
end
