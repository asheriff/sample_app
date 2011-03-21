require 'spec_helper'

describe UsersController do
  render_views
  
  before(:each) do
    @base_title = "My Silly Rials App"
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    
    it "should have right title" do
      get 'new'
      response.should have_selector("title",
        :content => "#{@base_title} :: Sign Up"
      )
    end
  end
  
  describe "GET 'show'" do
    before :each do
      @user = Factory(:user)
    end
    
    it "should be successful" do
      get 'show', :id => @user
      response.should be_success
    end
    
    it "should find the correct user" do
      get 'show', :id => @user
      assigns(:user).should == @user
    end
    
    it "should have the right title" do
      get 'show', :id => @user
      response.should have_selector("title",
        :content => "#{@base_title} :: #{@user.name}"
      )
    end
    
    it "should have the right H1 heading" do
      get 'show', :id => @user
      response.should have_selector("h1",
        :content => @user.name
      )
    end
    
    it "should have a profile image" do
      get 'show', :id => @user
      response.should have_selector("img",
        :class => "gravatar",
        :alt => "#{@user.name} Gravatar"
      )
    end
  end
end
