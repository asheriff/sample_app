Factory.define :user do |user|
  user.name "Fred Flintstone"
  user.email "fred@slate.com"
  user.password "foobar"
  user.password_confirmation "foobar"
end

Factory.sequence :email do |n|
  "user-#{n}@foo.com"
end
