require 'spec_helper'

describe Micropost do
  before :each do
    @user = Factory(:user)
    @attrs = { :content=>"micropost content" }
  end
  
  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attrs)
  end
  
  describe "user associations" do
    before :each do
      @micropost = @user.microposts.create(@attrs)
    end
    
    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end
    
    it "should have the correct associated user" do
      @micropost.user_id.should eq @user.id
      @micropost.user.should eq @user
    end
  end
  
  describe "validations" do
    it "should require a user id" do
      Micropost.new(@attrs).should_not be_valid
    end
    
    it "should not allow blank content" do
      @user.microposts.build(:content=>" ").should_not be_valid
    end
    
    it "should reject long content" do
      @user.microposts.build(:content=>"a"*141).should_not be_valid
    end
  end
  
  describe "self.from_users_followed_by" do
    before :each do
      @user_2 = Factory(:user, :email=>Factory.next(:email))
      @user_3 = Factory(:user, :email=>Factory.next(:email))
      
      @user_post = @user.microposts.create!( :content=>"foo" )
      @user_2_post = @user_2.microposts.create!( :content=>"bar" )
      @user_3_post = @user_3.microposts.create!( :content=>"baz" )
      
      @user.follow!( @user_2 )
    end
    
    it "should have a from_users_followed_by method" do
      Micropost.should respond_to(:from_users_followed_by)
    end
    
    it "should include the user's own microposts" do
      Micropost.from_users_followed_by(@user).should include(@user_post)
    end
    
    it "should include the followed user's microposts" do
      Micropost.from_users_followed_by(@user).should include(@user_2_post)
    end
    
    it "should not include the un-followed user's microposts" do
      Micropost.from_users_followed_by(@user).should_not include(@user_3_post)
    end
  end
end
