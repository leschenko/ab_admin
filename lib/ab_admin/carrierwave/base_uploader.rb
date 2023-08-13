require 'mini_magick'
require 'carrierwave/processing/mini_magick'

module AbAdmin
  module CarrierWave
    class BaseUploader < ::CarrierWave::Uploader::Base
      include ::CarrierWave::MiniMagick
      include AbAdmin::Utils::EvalHelpers

      class_attribute :human_filenames
      self.human_filenames = true

      attr_accessor :internal_identifier

      before :cache, :save_original_name

      storage :file

      with_options if: :image? do |img|
        img.process :strip
        img.process cropper: lambda { |model| model.cropper_geometry }
        img.process rotate: lambda { |model| model.rotate_degrees }
      end

      process :set_model_info

      def filename
        "#{[human_part, secure_token].compact.join('_')}#{extension}"
      end

      def full_filename(*)
        return filename unless version_name
        base = "#{version_filename_part}#{version_extension}"
        return base unless human_filenames
        [human_part, base].compact.join('_')
      end

      def human_part
        normalize_filename(model.send("#{mounted_as}_file_name").to_s.strip.remove(/\.\w+$/)).remove(secure_token).chomp('_').presence
      end

      def extension
        File.extname(model.original_name).downcase
      end

      def version_extension
        webp? ? '.webp' : extension
      end

      def version_filename_part
        return secure_token unless version_name
        strict_version_name = version_name.to_s.remove('retina_').remove('_webp')
        strict_version_name = nil if strict_version_name.to_sym == :default
        "#{strict_version_name}#{'@2x' if retina?}"
      end

      def secure_token
        model.data_secure_token ||= AbAdmin.friendly_token(20).downcase
      end

      def retina?
        version_name.to_s.start_with?('retina_')
      end

      def webp?
        version_name.to_s.end_with?('_webp')
      end

      def store_model_filename(record)
        old_file_name = filename
        new_file_name = model_filename(old_file_name, record)
        return if new_file_name.blank? || new_file_name == old_file_name
        rename_via_move(new_file_name)
      end

      def save_original_name(file)
        model.original_name ||= file.original_filename if file.respond_to?(:original_filename)
      end

      def model_filename(base_filename, record)
        custom_file_name = model.build_filename(base_filename, record)
        return unless custom_file_name
        normalize_filename(custom_file_name)
      end
      private :model_filename

      def normalize_filename(raw_filename)
        I18n.transliterate(raw_filename.unicode_normalize).parameterize(separator: '_').gsub(/[\-_]+/, '_').downcase
      end

      def rename_via_move(new_filename)
        dir = File.dirname(path)
        old_names = versions.values.unshift(self).map(&:full_filename)
        model.send("#{mounted_as}_file_name=", "#{[new_filename.presence, secure_token].compact.join('_')}#{extension}")
        new_names = versions.values.unshift(self).map(&:full_filename)
        old_names.zip(new_names).each do |old_name, new_name|
          old_path, new_path = File.join(dir, old_name), File.join(dir, new_name)
          next if old_path == new_path || !File.exist?(old_path)
          FileUtils.mv(old_path, new_path)
        end
        retrieve_from_store!(model.send("#{mounted_as}_file_name"))
      end

      def store_dir
        str_id = model.id.to_s.rjust(4, '0')
        [AbAdmin.uploads_dir, model.class.to_s.underscore, str_id[0..2], str_id[3..-1]].join('/')
      end

      def convert_to_webp(options = {})
        webp_path = "#{File.dirname(path)}/#{full_filename}"
        WebP.encode(path, webp_path, options_for_webp(options))
        @file = ::CarrierWave::SanitizedFile.new(tempfile: webp_path, filename: webp_path, content_type: 'image/webp')
      end

      def options_for_webp(options)
        w, h = width, height
        options = options.dup
        ratio = w.to_f / h
        if options[:resize_to_fill]
          res_w, res_h = options[:resize_to_fill]
          res_ratio = res_w.to_f / res_h
          options.update(resize_w: res_w, resize_h: res_h) unless w == res_w && h == res_h
          if ratio > res_ratio
            crop_res_w = h * res_ratio
            crop_res_h = h
            options.update(crop_x: ((w - crop_res_w) / 2).to_i, crop_y: 0, crop_w: crop_res_w.to_i, crop_h: crop_res_h.to_i)
          elsif ratio < res_ratio
            crop_res_w = w
            crop_res_h = w / res_ratio
            options.update(crop_x: 0, crop_y: ((h - crop_res_h) / 2).to_i, crop_w: crop_res_w.to_i, crop_h: crop_res_h.to_i)
          end
        elsif options[:resize_to_fit]
          res_w, res_h = options[:resize_to_fit]
          res_ratio = res_w.to_f / res_h
          if ratio == res_ratio
            options.update(resize_w: res_w, resize_h: res_h) unless w == res_w && h == res_h
          elsif ratio > res_ratio
            options.update(resize_w: res_h)
          elsif ratio < res_ratio
            options.update(resize_h: res_w)
          end
        end
        options.except(:resize_to_fill, :resize_to_fit)
      end

      # Strips out all embedded information from the image
      # process :strip
      #
      def strip
        minimagick! do |img|
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
          minimagick! do |img|
            img.quality percentage.to_s
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
            self.class.included_modules.map(&:to_s).include?('CarrierWave::RMagick') ? img.rotate!(degrees.to_i) : img.rotate(degrees.to_s)
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
          minimagick! do |img|
            img.crop '%ix%i+%i+%i' % geometry
            img = yield(img) if block_given?
            img
          end
        end
      end

      def watermark(watermark_path, gravity='SouthEast')
        minimagick! do |img|
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
        AbAdmin.image_types.include?((file || new_file).content_type)
      end

      def dimensions
        [width, height]
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
