module AbAdmin
  module Controllers
    module Tree
      def rebuild
        parent_id = params[:parent_id].to_i
        prev_id = params[:prev_id].to_i
        next_id = params[:next_id].to_i

        head(:bad_request) and return if parent_id.zero? && prev_id.zero? && next_id.zero?

        if prev_id.zero? && next_id.zero?
          resource.move_to_child_of resource_class.find(parent_id)
        elsif !prev_id.zero?
          resource.move_to_right_of resource_class.find(prev_id)
        elsif !next_id.zero?
          resource.move_to_left_of resource_class.find(next_id)
        end

        head :ok
      end
    end
  end
end