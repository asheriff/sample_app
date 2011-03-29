begin
  require 'faker'
rescue LoadError
end

namespace :db do
  desc "Insert dummy data"
  task :populate do
    Rake::Task['db:reset'].invoke
    
    make_users()
    make_microposts()
    make_relationships()
  end
end

def make_users
  print "creating Users"
  
  admin = User.create!(
    :name => "Example User",
    :email => "example@user.com",
    :password => "foobar",
    :password_confirmation => "foobar"
  )
  admin.toggle!(:admin)
  
  99.times do |n|
    name = Faker::Name.name
    email = "example-#{n}@user.org"
    password = "password"
    
    User.create!(
      :name => name,
      :email => email,
      :password => password,
      :password_confirmation => password
    )
    dots
  end
  
  puts
end

def make_microposts
  print "creating Microposts"
  
  User.all(:limit=>6).each_with_index do |user,index|
    ((index+1)*10).times do
      user.microposts.create! :content=>Faker::Lorem.sentence(5)
      dots
    end
  end
  
  puts
end

def make_relationships
  print "creating Relationships"
  
  users = User.all
  user = users.first
  users[1..50].each{ |u| user.follow!(u); dots }
  users[3..40].each{ |u| u.follow!(user); dots }
  puts
end

private
  
  def dots
    print "."
    $stdout.flush
  end
