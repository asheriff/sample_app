require 'spec_helper'

describe PagesController do
  render_views
  
  before(:each) do
    @base_title = "My Silly Rials App"
  end

  %w(contact about help).each do |action|
    describe "GET '#{action}'" do
      it "should be successful" do
        get action
        response.should be_success
      end
      
      it "should have the correct title" do
        get action
        response.should have_selector("title",
          :content => "#{@base_title} :: #{action.capitalize}"
        )
      end
    end
  end
  
  describe "GET 'home'" do
    describe "when not authenticated" do
      before :each do
        get 'home'
      end
      
      it "should be successful" do
        response.should be_success
      end
      
      it "should have the correct title" do
        response.should have_selector("title",
          :content => "#{@base_title} :: Home"
        )
      end
    end
    
    describe "when authenticated" do
      before :each do
        @user = test_sign_in(Factory(:user))
        other_user = Factory(:user, :email=>Factory.next(:email))
        other_user.follow!(@user)
      end
      
      it "should " do
        get 'home'
        response.should have_selector("a",
          :href => following_user_path(@user),
          :content => "Following 0 users"
        )
        response.should have_selector("a",
          :href => followers_user_path(@user),
          :content => "Followed by 1 user"
        )
      end
    end
  end
  
  describe "home page" do
    describe "user info section" do
      before :each do
        @user = test_sign_in( Factory(:user) )
      end
      
      it "should show correct count and inflection when zero" do
        get "home"
        response.should have_selector(".micropost_count",
          :content => "0 microposts"
        )
      end
      
      it "should show correct count and inflection when one" do
        Factory(:micropost, :user=>@user)
        
        get "home"
        response.should have_selector(".micropost_count",
          :content => "1 micropost"
        )
      end
      
      it "should show correct count and inflection when many" do
        Factory(:micropost, :user=>@user)
        Factory(:micropost, :user=>@user)
        
        get "home"
        response.should have_selector(".micropost_count",
          :content => "2 microposts"
        )
      end
    end
  end
end
