module Admin::StructuresHelper

  def edit_structure_record_path(structure)
    case structure.structure_type
      when StructureType.static_page
        if structure.static_page
          edit_admin_structure_static_page_path(:structure_id => structure.id)
        else
          new_admin_structure_static_page_path(:structure_id => structure.id)
        end
      when StructureType.posts
        '#'
      when StructureType.main
        '#'
      when StructureType.redirect
        edit_admin_structure_path(structure)
      when StructureType.group
        '#'
      else
        '#'
    end
  end

end