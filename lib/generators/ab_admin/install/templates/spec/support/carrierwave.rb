def all_uploaders
  @all_uploaders ||= begin
    Dir[Rails.root.join('app/uploaders/*.rb')].each { |u| require u }
    AbAdmin::CarrierWave::BaseUploader.subclasses
  end
end

def enable_processing
  all_uploaders.each do |u|
    u.enable_processing = true
  end
end

def disable_processing
  all_uploaders.each do |u|
    u.enable_processing = false
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.around :each, :js do |example|
    enable_processing
    example.run
    disable_processing
  end

  config.after :all do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
  end
end

if defined?(CarrierWave)
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end

  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      def cache_dir
        "#{Rails.root}/spec/support/uploads/tmp"
      end

      def store_dir
        "#{Rails.root}/spec/support/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end
    end
  end
end