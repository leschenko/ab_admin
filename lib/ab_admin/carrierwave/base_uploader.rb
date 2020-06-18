require 'mini_magick'
require 'carrierwave/processing/mini_magick'

module AbAdmin
  module CarrierWave
    class BaseUploader < ::CarrierWave::Uploader::Base
      include ::CarrierWave::MiniMagick
      include AbAdmin::Utils::EvalHelpers

      class_attribute :transliterate, :human_filenames
      self.transliterate = true
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

      def save_original_name(file)
        model.original_name ||= file.original_filename if file.respond_to?(:original_filename)
      end

      def strict_filename(for_file=filename)
        "#{version_name || secure_token}#{File.extname(for_file).downcase}"
      end

      def base_filename_part
        return if version_name.to_s.remove('retina_').remove('_webp').to_sym == :default
        return secure_token unless version_name
        res = version_name.to_s
        res = "#{res.remove(/^retina_/)}@2x" if version_name.to_s.start_with?('retina_')
        res = "#{res.remove(/_webp$/)}" if version_name.to_s.end_with?('_webp')
        res
      end

      def full_filename(for_file=filename)
        human_filenames ? human_full_filename(for_file) : strict_filename(for_file)
      end

      def human_full_filename(for_file=filename)
        ext = version_name.to_s.end_with?('_webp') ? '.webp' : File.extname(for_file)
        system_part = base_filename_part
        human_filename_part = for_file.chomp(File.extname(for_file))
        return "#{system_part || version_name}#{ext}" if human_filename_part == secure_token
        system_part ? "#{human_filename_part}_#{system_part}#{ext}" : "#{human_filename_part}#{ext}"
      end

      def full_original_filename
        "#{base_filename_part}#{File.extname(store_filename)}"
      end

      # use secure token in the filename for non processed image
      def secure_token
        model.data_secure_token ||= AbAdmin.friendly_token(20).downcase
      end

      def store_model_filename(record)
        old_file_name = filename
        new_file_name = model_filename(old_file_name, record)
        return if new_file_name.blank? || new_file_name == old_file_name
        rename_via_move(new_file_name)
      end

      alias_method :store_filename, :filename

      def filename
        internal_identifier || model.send("#{mounted_as}_file_name") || (store_filename && "#{secure_token}#{File.extname(store_filename).downcase}")
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
        normalize_filename(custom_file_name) + File.extname(base_filename).downcase
      end

      def normalize_filename(raw_filename)
        parameterize_args = ActiveSupport::VERSION::MAJOR > 4 ? {separator: '_'} : '_'
        I18n.transliterate(raw_filename).parameterize(**parameterize_args).gsub(/[\-_]+/, '_').downcase
      end

      # rename files via move
      def rename_via_move(new_file_name)
        if human_filenames
          dir = File.dirname(path)

          moves = []
          versions.values.unshift(self).each do |v|
            from_path = File.join(dir, v.full_filename)
            to_path = File.join(dir, v.full_filename(new_file_name))
            next if from_path == to_path || !File.exists?(from_path)
            moves << [from_path, to_path]
          end
          moves.each { |move| FileUtils.mv(*move) }
        end

        write_internal_identifier new_file_name
        model.send("write_#{mounted_as}_identifier")
        retrieve_from_store!(new_file_name) if human_filenames

        new_file_name
      end

      private :write_internal_identifier, :store_filename, :model_filename

      def rmagick_included?
        self.class.included_modules.map(&:to_s).include?('CarrierWave::RMagick')
      end

      # prevent large number of subdirectories
      def store_dir
        str_id = model.id.to_s.rjust(4, '0')
        [AbAdmin.uploads_dir, model.class.to_s.underscore, str_id[0..2], str_id[3..-1]].join('/')
      end

      def convert_to_webp(options = {})
        webp_path = "#{File.dirname(path)}/#{filename.sub(/\.\w+$/, '.webp')}"
        WebP.encode(path, webp_path, options_for_webp(options))
        write_internal_identifier webp_path.split('/').pop
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
            rmagick_included? ? img.rotate!(degrees.to_i) : img.rotate(degrees.to_s)
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
