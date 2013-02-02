# encoding: utf-8
#FactoryGirl.define do
#  factory :asset_avatar, :class => Avatar do |a|
#    #include ActionDispatch::TestProcess
#    a.data File.open('spec/factories/files/rails.png')
#    a.association :assetable, :factory => :default_user
#
#    before(:create) do |instance|
#      instance.data_content_type ||= 'image/png'
#    end
#  end
#
#  factory :asset_avatar_big, :class => Avatar do |a|
#    a.data File.open('spec/factories/files/silicon_valley.jpg')
#    a.association :assetable, :factory => :default_user
#
#    before(:create) do |instance|
#      instance.data_content_type ||= 'image/jpg'
#    end
#  end
#end
# encoding: utf-8
FactoryGirl.define do
  factory :asset_avatar, :class => Avatar do
    #include ActionDispatch::TestProcess
    data File.open(File.expand_path('../files/rails.png', __FILE__))
    association :assetable, :factory => :default_user

    before(:create) do |instance|
      instance.data_content_type ||= 'image/png'
    end
  end

  factory :asset_avatar_big, :class => Avatar do
    data File.open(File.expand_path('../files/silicon_valley.jpg', __FILE__))
    association :assetable, :factory => :default_user

    before(:create) do |instance|
      instance.data_content_type ||= 'image/jpg'
    end
  end

  factory :picture do
    data File.open(File.expand_path('../files/rails.png', __FILE__))
    association :assetable, :factory => :structure
    is_main true

    before(:create) do |instance|
      instance.data_content_type ||= 'image/jpg'
    end
  end
end
