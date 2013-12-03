# encoding: utf-8
require 'mime/types'
require 'mini_magick'
require 'carrierwave/processing/mini_magick'
require 'carrierwave/processing/mime_types'

module AbAdmin
  module CarrierWave
    class BaseUploader < ::CarrierWave::Uploader::Base
      include ::CarrierWave::MiniMagick
      include ::CarrierWave::MimeTypes
      include AbAdmin::Utils::EvalHelpers

      class_attribute :transliterate
      self.transliterate = true

      attr_accessor :model_identifier

      before :cache, :save_original_name

      storage :file

      process :set_content_type

      with_options if: :image? do |img|
        img.process :strip
        img.process cropper: lambda { |model| model.cropper_geometry }
        img.process rotate: lambda { |model| model.rotate_degrees }
      end

      process :set_model_info

      def save_original_name(file)
        model.original_name ||= file.original_filename if file.respond_to?(:original_filename)
      end

      def full_filename(for_file=db_filename)
        if for_file.present?
          ext = File.extname(for_file)
          human_filename_part = for_file.chomp(ext)
          tech_filename_part = "#{version_name || secure_token}#{ext}"
          human_filename_part == secure_token ? tech_filename_part : "#{human_filename_part}_#{tech_filename_part}"
        else
          "#{version_name || secure_token}#{File.extname(store_filename)}"
        end
      end

      def full_original_filename
        "#{version_name || secure_token}#{File.extname(store_filename)}"
      end

      # use secure token in the filename for non processed image
      def secure_token
        model.data_secure_token ||= SecureRandom.urlsafe_base64.first(20).downcase
      end

      def store_model_filename
        old_file_name = db_filename
        new_file_name = model_filename(old_file_name)
        return if new_file_name.blank? || new_file_name == old_file_name
        rename_via_move new_file_name
        write_model_identifier new_file_name
      end

      alias_method :store_filename, :filename

      def filename
        model_identifier || "#{secure_token}#{File.extname(store_filename)}"
      end

      def db_filename
        model_identifier || model.send("#{mounted_as}_file_name")
      end

      def write_model_identifier(model_identifier)
        self.model_identifier = model_identifier
      end

      # transliterate original filename
      # allow to build custom filename
      def model_filename(base_filename)
        custom_file_name = model.build_filename(base_filename)
        return unless custom_file_name
        I18n.transliterate(custom_file_name).parameterize('_').downcase + File.extname(base_filename)
      end

      # rename files via move
      def rename_via_move(new_file_name)
        dir = File.dirname(path)
        for_move = []
        for_move << [File.join(dir, full_filename), File.join(dir, full_filename(new_file_name))]
        self.class.versions.keys.each do |version_name|
          self.class.version_names = [version_name]
          for_move << [File.join(dir, full_filename), File.join(dir, full_filename(new_file_name))]
        end
        for_move.each { |move| FileUtils.mv(move[0], move[1]) }

        self.class.version_names = nil
      end

      private :write_model_identifier, :db_filename, :store_filename, :model_filename

      # prevent large number of subdirectories
      def store_dir
        str_id = model.id.to_s.rjust(4, '0')
        "uploads/#{model.class.to_s.underscore}/#{str_id[0..2]}/#{str_id[3..-1]}"
      end

      # Strips out all embedded information from the image
      # process :strip
      #
      def strip
        manipulate! do |img|
          img.strip
          img = yield(img) if block_given?
          img
        end
      end

      # Reduces the quality of the image to the percentage given
      # process quality: 85
      #
      def quality(percentage)
        percentage = normalize_param(percentage)

        unless percentage.blank?
          manipulate! do |img|
            img.quality(percentage.to_s)
            img = yield(img) if block_given?
            img
          end
        end
      end

      # Rotate image by degress
      # process rotate: "-90"
      #
      def rotate(degrees = nil)
        degrees = normalize_param(degrees)

        unless degrees.blank?
          manipulate! do |img|
            img.rotate(degrees.to_s)
            img = yield(img) if block_given?
            img
          end
        end
      end

      # Crop image by specific coordinates
      # http://www.imagemagick.org/script/command-line-processing.php?ImageMagick=6ddk6c680muj4eu2vr54vdveb7#geometry
      # process cropper: [size, offset]
      # process cropper: [800, 600, 10, 20]
      #
      def cropper(*geometry)
        geometry = normalize_param(geometry[0]) if geometry.size == 1

        if geometry && geometry.size == 4
          manipulate! do |img|
            img.crop '%ix%i+%i+%i' % geometry
            img = yield(img) if block_given?
            img
          end
        end
      end

      def watermark(path_to_file, gravity='SouthEast')
        manipulate! do |img|
          logo = ::MiniMagick::Image.open(path_to_file)
          img.composite(logo) { |c| c.gravity gravity }
        end
      end

      def default_url
        image_name = [model.class.to_s.underscore, version_name].compact.join('_')
        "/assets/defaults/#{image_name}.png"
      end

      def image?(new_file = nil)
        (file || new_file).content_type.include? 'image'
      end

      def dimensions
        [magick[:width], magick[:height]]
      end

      def magick
        #@magick ||= ::MiniMagick::Image.new(current_path)
        ::MiniMagick::Image.new(current_path)
      end

      protected

        def set_model_info
          model.data_content_type = file.content_type
          model.data_file_size = file.size

          if image? && model.has_dimensions?
            model.width, model.height = dimensions
          end
        end

        def normalize_param(value)
          if value.is_a?(Proc) || value.is_a?(Method)
            evaluate_method(model, value, file)
          else
            value
          end
        end
    end
  end
end
