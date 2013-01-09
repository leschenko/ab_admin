# encoding: utf-8

def insert_user  
  User.truncate!
  password = Rails.env.production? ? Devise.friendly_token : (1..9).to_a.join
  
  admin = User.new do |u|
    u.name = "Administrator"
    u.email = 'dev@example.com'
    u.password = password
    u.password_confirmation = password
    u.user_role_id = UserRoleType.admin.id
  end
    
  admin.skip_confirmation!
  admin.save!

  puts "Admin: #{admin.email}, #{admin.password}"
end

def insert_structures
  Structure.truncate!
  
  main_page = Structure.create!({:title => "Главная страница", :slug => "main-page", :structure_type => StructureType.main, :parent => nil}, :as => :admin)
  #Structure.create!({:title => "Трансляции", :slug => "broadcasts", :structure_type => StructureType.broadcasts, :parent => main_page}, :as => :admin)
  #Structure.create!({:title => "Прямые репортажи", :slug => "posts", :structure_type => StructureType.posts, :parent => main_page}, :as => :admin)
end

insert_user
insert_structures
