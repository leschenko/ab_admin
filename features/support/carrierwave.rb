#FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])

if defined?(CarrierWave)
  #CarrierWave.configure do |config|
  #  config.storage = :file
  #  config.enable_processing = false
  #end

  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      def cache_dir
        "#{Rails.root}/public/tmp/spec/uploads/tmp"
      end

      def store_dir
        "#{Rails.root}/public/tmp/spec/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end
    end
  end
end