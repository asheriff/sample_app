require 'spec_helper'

describe User do
  before :each do
    @attrs = {
      :name => "Jon Doe",
      :email => "jdoe@foo.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
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
  
  describe "password validations" do
    it "should require a password" do
      user = User.new( @attrs.merge(:password=>"", :password_confirmation=>"") )
      user.valid?.should eq false
    end
    
    it "should require a matching password confirmation" do
      user = User.new( @attrs.merge(:password=>"foobar", :password_confirmation=>"wrongpass") )
      user.valid?.should eq false
    end
    
    it "should reject short passwords" do
      pass = "a"*5
      user = User.new( @attrs.merge(:password=>pass, :password_confirmation=>pass) )
      user.valid?.should eq false
    end
    
    it "should reject long passwords" do
      pass = "a"*41
      user = User.new( @attrs.merge(:password=>pass, :password_confirmation=>pass) )
      user.valid?.should eq false
    end
  end
  
  describe "password encryption" do
    before :each do
      @user = User.create!(@attrs)
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "method #has_password?" do
      it "should be true if passwords match" do
        @user.has_password?(@attrs[:password]).should be_true
      end
      
      it "should be false if passwords don't match" do
        @user.has_password?("wrongpass").should be_false
      end
    end
    
    describe "User.authenticate" do
      it "should return nil for password/email mismatch" do
        user = User.authenticate(@attrs[:email], "wrongpass")
        user.should be_nil
      end
      
      it "should return nil when no email address exists" do
        user = User.authenticate("nobody@foo.com", @attrs[:password])
        user.should be_nil
      end
      
      it "should return the user if password/email match" do
        user = User.authenticate(@attrs[:email], @attrs[:password])
        user.should eq @user
      end
      
    end
  end
end
