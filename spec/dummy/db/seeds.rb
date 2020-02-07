def insert_user
  User.truncate!
  password = Rails.env.production? ? Devise.friendly_token : (1..8).to_a.join
  
  admin = User.new do |u|
    u.email = 'admin@example.com'
    u.password = password
    u.password_confirmation = password
    u.user_role_id = UserRoleType.admin.id
  end
    
  admin.activate!
  admin.save!

  puts "Admin: #{admin.email}, #{admin.password}"
end

def insert_structures
  Structure.truncate!
  Structure.create!(title: 'Main page', slug: 'main-page', structure_type: StructureType.main, parent: nil)
end

insert_user
insert_structures

Dir[File.join(Rails.root.join('../factories'), '*.rb')].each { |f| load f }
def test_structure
  Structure.truncate!

  Structure.create!(title: 'Main page', slug: 'main-page', structure_type: StructureType.main, parent: nil)
  3.times do |i|
    parent = FactoryBot.create(:structure_page, title: "node #{i}")
    2.times do |ii|
      child = FactoryBot.create(:structure_page, title: "node #{i} - #{ii}", parent: parent)
      2.times do |iii|
        FactoryBot.create(:structure_page, title: "node #{i} - #{ii} - #{iii}", parent: child)
      end
    end
  end
  Structure.rebuild!
end
