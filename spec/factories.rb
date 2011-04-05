Factory.sequence :email do |n|
  "user-#{n}@foo.com"
end

Factory.sequence :name do |n|
  "user-#{n}"
end

Factory.define :user do |obj|
  obj.after_build do |user|
    user.name = Factory.next(:name)
    user.email = Factory.next(:email)
    user.password = "foobar"
    user.password_confirmation = "foobar"
  end
end

Factory.define :micropost do |micropost|
  micropost.content "Foo bar"
  micropost.association :user
end
