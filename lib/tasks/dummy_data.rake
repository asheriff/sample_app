require 'faker'

namespace :db do
  desc "Insert dummy data"
  task :populate do
    Rake::Task['db:reset'].invoke
    
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
    end
    
    User.all(:limit=>6).each_with_index do |user,index|
      ((index+1)*10).times do
        user.microposts.create! :content=>Faker::Lorem.sentence(5)
      end
    end
  end
end
