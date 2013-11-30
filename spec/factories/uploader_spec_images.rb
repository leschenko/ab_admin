FactoryGirl.define do
  factory :uploader_spec_image do
    data File.open(File.expand_path('../files/А и б.png', __FILE__))

    before(:create) do |instance|
      instance.data_content_type ||= 'image/png'
    end

    trait :bad_filename do
      data File.open(File.expand_path('../files/Тест : \n . - +.png', __FILE__))
    end
  end
end
