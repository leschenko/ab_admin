# -*- encoding : utf-8 -*-
module AbAdmin
  module Mailers
    module MailAttachHelper

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          helper_method :image_to_attach
        end
      end

      class MailAttacher
        attr_accessor :text, :images

        def initialize(text)
          @text = text.gsub(/(\n|\t|\r)/, ' ').gsub(/>\s*</, '><').squeeze(' ')
          @images = []
          parse_images
        end

        def parse_images
          raw_res = @text.scan(/<img[^>]*?src="(\/[^"]*)/).flatten
          raw_res.map do |r|
            r_clear = r.gsub(/\?[^?]*$/, '')
            @images << [r, Rails.root.join('public', r_clear.slice(1..-1)).to_s, File.basename(r_clear)]
          end
          @images
        end

        def replace_attaches(attaches)
          @images.each do |image|
            @text = @text.gsub(image[0], attaches[image[2]].try(:url))
          end
          @text
        end

      end

      module InstanceMethods
        def image_to_attach(text)
          prepare_attachments(text).replace_attaches(attachments)
        end

        def prepare_attachments(text)
          parsed = MailAttacher.new(text)
          parsed.images.each do |image|
            attachments.inline[image[2]] = File.read(image[1])
          end
          parsed
        end
      end

    end
  end
end
