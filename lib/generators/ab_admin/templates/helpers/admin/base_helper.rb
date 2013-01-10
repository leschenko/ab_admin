# -*- encoding : utf-8 -*-
module Admin
  module BaseHelper

    def layout_css
      css = []
      css << 'content_with_sidebar' if with_sidebar?
      css << 'well' if (collection_action? && settings[:well]) || action_name == 'show'
      css << "#{settings[:index_view]}_view"
      css
    end

    def admin_comments
      render 'admin/admin_comments/comments'
    end

    def color_bool(val, success_class='badge-success')
      %(<span class="badge #{success_class if val}">#{val ? '+' : '-'}</span>).html_safe
    end

    def icon(name, white=false)
      "<i class='icon-#{name} #{'icon-white' if white}'></i> ".html_safe
    end

    def item_image_link(item, url, assoc=:photo, version=:thumb)
      image = item.send(assoc)
      return nil unless image
      popover_data = {:content => "<img src='#{image.url}'></img>", :title => item.name}
      link_to image_tag(image.url(version)), url, :data => popover_data, :rel => 'popover'
    end

    def item_image(item, assoc=:photo, size=:thumb)
      image_tag_if(item.send(assoc).try(:url, size))
    end

    # input_set 'title', :legend_class => 'do_sort', :label_class => 'label-info' do
    def input_set(title, options={}, &block)
      options.reverse_merge!(:class => "inputs well well-small #{options.delete(:legend_class) || 'do_sort'}", :id => options.delete(:legend_id))
      html = content_tag(:label, title, :class => "input_set label #{options.delete(:label_class)}")
      html.concat(capture(&block)) if block_given?
      content_tag(:fieldset, html, options)
    end

    def ha(attr)
      resource_class.han(attr)
    end

    def call_method_or_proc_on(obj, symbol_or_proc, options = {})
      exec = options[:exec].nil? ? true : options[:exec]
      case symbol_or_proc
        when Symbol, String
          obj.send(symbol_or_proc.to_sym)
        when Proc
          if exec
            instance_exec(obj, &symbol_or_proc)
          else
            symbol_or_proc.call(obj)
          end
      end
    end

  end
end
