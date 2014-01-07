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

      attr_accessor :internal_identifier

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

      def full_filename(for_file=filename)
        ext = File.extname(for_file)
        human_filename_part = for_file.chomp(ext)
        tech_filename_part = "#{version_name || secure_token}#{ext}"
        human_filename_part == secure_token ? tech_filename_part : "#{human_filename_part}_#{tech_filename_part}"
      end

      def full_original_filename
        "#{version_name || secure_token}#{File.extname(store_filename)}"
      end

      # use secure token in the filename for non processed image
      def secure_token
        model.data_secure_token ||= SecureRandom.urlsafe_base64.first(20).downcase
      end

      def store_model_filename(record)
        old_file_name = filename
        new_file_name = model_filename(old_file_name, record)
        return if new_file_name.blank? || new_file_name == old_file_name
        rename_via_move(new_file_name)
      end

      alias_method :store_filename, :filename

      def filename
        internal_identifier || model.send("#{mounted_as}_file_name") || (store_filename && "#{secure_token}#{File.extname(store_filename)}")
      end

      def write_internal_identifier(internal_identifier)
        self.internal_identifier = internal_identifier
        versions.values.each{|v| v.internal_identifier = internal_identifier }
      end

      # transliterate original filename
      # allow to build custom filename
      def model_filename(base_filename, record)
        custom_file_name = model.build_filename(base_filename, record)
        return unless custom_file_name
        normalize_filename(custom_file_name) + File.extname(base_filename)
      end

      def normalize_filename(raw_filename)
        I18n.transliterate(raw_filename).parameterize('_').downcase
      end

      # rename files via move
      def rename_via_move(new_file_name)
        dir = File.dirname(path)

        moves = []
        versions.values.unshift(self).each do |v|
          from_path = File.join(dir, v.full_filename)
          to_path = File.join(dir, v.full_filename(new_file_name))
          return false if from_path == to_path || !File.exists?(from_path)
          moves << [from_path, to_path]
        end
        moves.each { |move| FileUtils.mv(*move) }

        write_internal_identifier new_file_name
        model.send("write_#{mounted_as}_identifier")
        retrieve_from_store!(new_file_name)
        new_file_name
      end

      private :write_internal_identifier, :store_filename, :model_filename

      # prevent large number of subdirectories
      def store_dir
        str_id = model.id.to_s.rjust(4, '0')
        [AbAdmin.uploads_dir, model.class.to_s.underscore, str_id[0..2], str_id[3..-1]].join('/')
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

      def watermark(watermark_path, gravity='SouthEast')
        manipulate! do |img|
          resolved_path = watermark_path.is_a?(Symbol) ? send(watermark_path) : watermark_path
          watermark_image = ::MiniMagick::Image.open(resolved_path)
          img.composite(watermark_image) { |c| c.gravity gravity }
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
