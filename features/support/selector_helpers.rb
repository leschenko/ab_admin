module SelectorHelpers
  def chosen_select(item_text, options)
    field_id = find_field(options[:from])[:id]
    option_value = page.evaluate_script("$(\"##{field_id} option:contains('#{item_text}')\").val()")
    page.execute_script("$('##{field_id}').val('#{option_value}')")
  end
end

World(::SelectorHelpers)

#module Capybara
#  module Node
#    class Element
#      def hover
#        @session.driver.browser.action.move_to(self.native).perform
#      end
#    end
#  end
#end