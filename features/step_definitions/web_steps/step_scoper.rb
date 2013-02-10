# Single-line step scoper
When /^(.*) within ([^:]+)$/ do |step_def, parent|
  with_scope(parent) { step step_def }
end

# Multi-line step scoper
When /^(.*) within ([^:]+):$/ do |step_def, parent, table_or_string|
  with_scope(parent) { step "#{step_def}:", table_or_string }
end
