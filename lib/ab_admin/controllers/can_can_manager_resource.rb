class AbAdmin::Controllers::CanCanManagerResource < CanCan::InheritedResource
  delegate :resource_class, to: :@controller

  def instance_name
    @controller.send(:resource_instance_name)
  end

end