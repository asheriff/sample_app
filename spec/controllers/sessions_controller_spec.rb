require 'spec_helper'

describe SessionsController do
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
        :content => "#{@base_title} :: Sign In"
      )
    end
  end
  
  describe "POST 'create'" do
    describe "with invalid credentials" do
      before :each do
        @attrs = { :email=>"jane@doe.com", :password=>"badpass" }
      end
      
      it "should re-render the new page" do
        post "create", :session=>@attrs
        response.should render_template("new")
      end
      
      it "should have the correct title" do
        post "create", :session=>@attrs
        response.should have_selector("title",
          :content => "#{@base_title} :: Sign In"
        )
      end
      
      it "should have a flash.now message" do
        post "create", :session=>@attrs
        flash.now[:error].should =~ /invalid/i
      end
    end
    
    describe "with valid credentials" do
      before :each do
        @user = Factory(:user)
        @attrs = {
          :email => @user.email,
          :password => @user.password,
        }
      end
      
      it "should sign the user in" do
        post "create", :session=>@attrs
        controller.current_user.should eq @user
        controller.should be_signed_in
      end
      
      it "should redirect to the show user page" do
        post "create", :session=>@attrs
        response.should redirect_to(user_path(@user))
      end
    end
  end
end
