notification :growl
ignore /vendor/, /public/, /etc/

group :rspec do
  guard 'rspec', all_on_start: false, all_after_pass: false, cli: ('--tag @focus' if ENV['FOCUS']) do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb') { 'spec' }

    # Rails example
    watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/(.*)(\.slim|\.erb|\.haml)$}) { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$}) { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/features/#{m[1]}_spec.rb"] }
    watch(%r{^spec/support/(.+)\.rb$}) { 'spec' }
    watch('config/routes.rb') { 'spec/routing' }
    watch('app/controllers/application_controller.rb') { 'spec/controllers' }
    watch(%r{lib/generators/ab_admin/.+/(.+)\.rb}) { |m| "spec/generators/#{m[1]}_spec.rb" }

    # Capybara request specs
    watch(%r{^app/views/(.+)/.*\.(slim|erb|haml)$}) { |m| "spec/features/#{m[1]}_spec.rb" }

    # Turnip features and steps
    #  watch(%r{^spec/acceptance/(.+)\.feature$})
    #  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$})   { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance' }
  end
end

group :cucumber do
  guard 'cucumber', cli: '--profile focus', all_after_pass: false, all_on_start: false do
    watch(%r{^features/.+\.feature$})
    watch(%r{^features/support/.+$}) { 'features' }
    watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
  end
end

