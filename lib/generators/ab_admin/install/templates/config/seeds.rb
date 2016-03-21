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

  main_page = Structure.create!({title: 'Главная страница', slug: 'main-page', structure_type: StructureType.main, parent: nil}, as: :admin)
end


insert_user
insert_structures
