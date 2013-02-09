# init gems list
gem('devise')
gem('devise-encryptable')
gem('awesome_nested_set')
gem('russian')
gem('ab_admin')

gem('thin', :group => 'development')

# run bundle install
run('bundle install --path=vendor/bundle --binstubs')

# run default generators
generate('devise:install')
generate('sunrise:install')

# copy migrations
rake('ab_admin:install:migrations')

# init git
if yes?('Init empty git?')
  git(:init)
end

# create && migrate database
if yes?('Run db tasks (create && migrate)?')
  rake('db:create')
  rake('db:migrate')
end