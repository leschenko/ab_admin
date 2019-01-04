FactoryBot.define do
  factory :avatar do
    #include ActionDispatch::TestProcess
    data { File.open(File.expand_path('../files/rails.png', __FILE__)) }
    association :assetable, factory: :default_user

    before(:create) do |instance|
      instance.data_content_type ||= 'image/png'
    end
  end

  factory :avatar_big, class: 'Avatar' do
    data { File.open(File.expand_path('../files/silicon_valley.jpg', __FILE__)) }
    association :assetable, factory: :default_user

    before(:create) do |instance|
      instance.data_content_type ||= 'image/jpg'
    end
  end

  factory :picture do
    data { File.open(File.expand_path('../files/rails.png', __FILE__)) }
    association :assetable, factory: :structure_page
    is_main { true }

    before(:create) do |instance|
      instance.data_content_type ||= 'image/jpg'
    end
  end
end
