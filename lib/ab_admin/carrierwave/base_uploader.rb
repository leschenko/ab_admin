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

      def full_filename(for_file)
        build_file_name for_file || filename
      end

      def full_original_filename
        build_file_name
      end

      def filename
        model.data_file_name || normalized_filename(super)
      end

      # version name to the end
      def build_file_name(base_file_name=filename)
        ext = File.extname(base_file_name)
        [base_file_name.chomp(ext), version_name || secure_token].compact.join('_') + ext
      end

      # transliterate original filename
      # allow to build custom filename
      def normalized_filename(base_filename)
        @transliterated_filename ||= begin
          custom_file_name = model.build_file_name(base_filename)
          result_filename = custom_file_name ? custom_file_name + File.extname(base_filename) : base_filename
          transliterate ? I18n.transliterate(result_filename).downcase : result_filename
        end
      end

      # use secure token in the filename for non cropped image
      def secure_token
        model.data_secure_token ||= SecureRandom.urlsafe_base64.first(20).downcase
      end

      # default store assets path
      def store_dir
        "uploads/#{model.class.to_s.underscore}/#{model.id}"
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
