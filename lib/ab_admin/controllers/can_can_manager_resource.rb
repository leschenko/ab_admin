class AbAdmin::Controllers::CanCanManagerResource < CanCan::InheritedResources
  def instance_name
    @controller.send(:resource_instance_name)
  end

  def resource_class
    @controller.send(:resource_class)
  end
end