module AbAdminContentsRollback

  def self.recorded_files
    @files ||= {}
  end

  # Records the contents of a file the first time we are
  # about to change it
  def self.record(filename)
    contents = File.read(filename) rescue nil
    recorded_files[filename] = contents unless recorded_files.has_key?(filename)
  end

  # Rolls the recorded files back to their original states
  def self.rollback!
    recorded_files.each do |filename, contents|
      # contents will be nil if the file didin't exist
      if contents.present?
        File.open(filename, 'w') {|f| f << contents }
      else
        File.delete(filename)

        # Delete parent directories
        begin
          dir = File.dirname(filename)
          until dir == Rails.root
            Dir.rmdir(dir)
            dir = dir.split('/')[0..-2].join('/')
          end
        rescue Errno::ENOTEMPTY
          # Directory not empty
        end

      end
    end

    @files = {}
  end

end

After do
  AbAdminContentsRollback.rollback!
end

Given /^a configuration of:$/ do |config|
  AbAdmin::AbstractResource.descendants.each { |c| Object.send(:remove_const, c.name.to_sym) rescue false }
  eval config
end

Given /^"([^"]*)" should contain:$/ do |filename, contents|
  filepath = Rails.root + filename
  File.read(filepath).strip.should == contents.strip
end

Given /^"([^"]*)" contains:$/ do |filename, contents|
  require 'fileutils'
  filepath = Rails.root + filename
  FileUtils.mkdir_p File.dirname(filepath)
  AbAdminContentsRollback.record(filepath)

  File.open(filepath, 'w+'){|f| f << contents }
end

Given /^I add "([^"]*)" to the "([^"]*)" model$/ do |code, model_name|
  filename = File.join(Rails.root, 'app', 'models', "#{model_name}.rb")
  AbAdminContentsRollback.record(filename)

  # Update the file
  contents = File.read(filename)
  File.open(filename, 'w+') do |f|
    f << contents.gsub(/^(class .+)$/, "\\1\n  #{code}\n")
  end

  ActiveSupport::Dependencies.clear
end

Given /^I should see routing error when follow "([^"]*)"$/ do |link|
  expect {
    click_link(link)
  }.to raise_error
end

Given /^I should see routing error on (.+)$/ do |page_name|
  expect {
    visit path_to(page_name)
  }.to raise_error
end

Given /^I should not see routing error on (.+)$/ do |page_name|
  expect {
    visit path_to(page_name)
  }.to_not raise_error
end