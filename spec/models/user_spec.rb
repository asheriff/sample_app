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
  
  describe "admin attribute" do
    before :each do
      @user = User.create!(@attrs)
    end
    
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    
    it "should not be an admin by default" do
      @user.admin?.should eq false
    end
    
    it "should be convertiable to an admin" do
      @user.toggle!(:admin)
      @user.admin?.should eq true
    end
  end
  
  describe "micropost associations" do
    before :each do
      @user = User.create(@attrs)
      @mp1 = Factory( :micropost, :user=>@user, :created_at=>1.day.ago )
      @mp2 = Factory( :micropost, :user=>@user, :created_at=>1.hour.ago )
    end
    
    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end
    
    it "should have the correct microposts in the correct order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    
    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
    
    describe "status feed" do
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      
      it "should include the user's microposts" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end
      
      it "should not include other user's microposts" do
        mp3 = Factory( :micropost, :user=>Factory( :user, :email=>Factory.next(:email) ) )
       @user.feed.include?(mp3).should be_false
      end
    end
  end
  
  describe "relationships" do
    before :each do
      @user = User.create!(@attrs)
      @followed = Factory(:user)
    end
    
    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end
    
    it "should have a following method" do
      @user.should respond_to(:following)
    end
    
    it "should have a following? method" do
      @user.should respond_to(:following?)
    end
    
    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end
    
    it "should follow another user" do
      @user.follow!(@followed)
      @user.following?(@followed).should be_true
    end
    
    it "should have the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.include?(@followed).should be_true
    end
    
    it "should have a unfollow! method" do
      @user.should respond_to(:unfollow!)
    end
    
    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.following.include?(@followed).should be_true
      @user.unfollow!(@followed)
      @user.following.include?(@followed).should be_false
    end
  end
end
