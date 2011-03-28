require 'spec_helper'

describe PagesController do
  render_views
  
  before(:each) do
    @base_title = "My Silly Rials App"
  end

  %w(home contact about help).each do |action|
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
