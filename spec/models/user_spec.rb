require 'spec_helper'

describe User do
  before :each do
    @attrs = { :name=>"Jon Doe", :email=>"jdoe@foo.com" }
  end
  
  it "should create new users given valid data" do
    User.create! @attrs
  end
  
  it "should require a name" do
    user = User.new( @attrs.merge(:name=>"") )
    user.valid?.should eq false
  end
  
  it "should reject long names" do
    name = "a"*51
    user = User.new( @attrs.merge(:name=>name) )
    user.valid?.should eq false
  end
  
  it "should require a email" do
    user = User.new( @attrs.merge(:email=>"") )
    user.valid?.should eq false
  end
  
  it "should reject invalid email addresses" do
    emails = %w(foo@bar,com foo_bar.com foo.bar@baz.)
    emails.each do |email|
      user = User.new( @attrs.merge(:email=>email) )
      user.valid?.should eq false
    end
  end
  
  it "should reject duplicate email addresses" do
    User.create! @attrs
    user2 = User.new @attrs.merge(:email=>@attrs[:email].upcase)
    user2.valid?.should eq false
  end
end
