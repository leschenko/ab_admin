# Single-line step scoper
When /^(.*) within "([^"]+)"$/ do |step_def, parent|
  within(parent) { step step_def }
end

# Multi-line step scoper
When /^(.*) within "([^"]+)":$/ do |step_def, parent, table_or_string|
  within(parent) { step "#{step_def}:", table_or_string }
end
