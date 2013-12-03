FactoryGirl.define do
  factory :base_uploader_spec_image, class: 'UploaderSpecImage' do
    trait :main_image do
      is_main true
    end

    trait :with_file do
      data File.open(File.expand_path('../files/А и б.png', __FILE__))
    end

    before(:create) do |instance|
      instance.data_content_type ||= 'image/png'
    end

    factory :uploader_spec_image, traits: [:with_file]
    factory :main_uploader_spec_image, traits: [:main_image, :with_file]
  end
end
