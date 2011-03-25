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
end
