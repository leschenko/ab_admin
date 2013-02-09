# -*- encoding : utf-8 -*-
module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

      when /the dashboard page/
        '/admin'

      when /the sign in page/
        '/users/sign_in'

      when /edit profile page/
        "/admin/users/#{@me.id}/edit"

      when /new admin product page/
        '/admin/products/new'

      when /edit admin product page/
        "/admin/products/#{@product.id}/edit"

      when /show admin product page/
        "/admin/products/#{@product.id}"

      when /the edit admin settings page/
        '/admin/settings/edit'

      when /the admin locators page/
        '/admin/locators'

      when /admin (\w+) page/
        "/admin/#{$1}"

      else
        begin
          page_name =~ /the (.*) page/
          path_components = $1.split(/\s+/)
          self.send(path_components.push('path').join('_').to_sym)
        rescue Object => e
          raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
                    "Now, go and add a mapping in #{__FILE__}"
        end
    end
  end
end

World(NavigationHelpers)
