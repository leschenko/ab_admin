class AbAdmin::Controllers::CanCanManagerResource < CanCan::InheritedResource
  delegate :resource_class, :to => :@controller
end