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
  
  describe "POST 'create'" do
    describe "failure" do
      before :each do
        @attrs = { :name=>"", :email=>"", :password=>"", :password_confirmation=>"" }
      end
      
      it "should not create a user" do
        lambda {
          post "create", :user=>@attrs
        }.should_not change(User, :count)
      end
      
      it "should have the correct title" do
        post "create", :user=>@attrs
        response.should have_selector("title",
          :content => "#{@base_title} :: Sign Up"
        )
      end
      
      it "should render the 'new' page" do
        post "create", :user=>@attrs
        response.should render_template('new')
      end
    end
    
    describe "success" do
      before :each do
        @attrs = { :name=>"New User", :email=>"user@foo.com", :password=>"foobar", :password_confirmation=>"foobar" }
      end
      
      it "should create a user" do
        lambda {
          post "create", :user=>@attrs
        }.should change(User, :count).by(1)
      end
      
      it "should sign the user in" do
        post "create", :user=>@attrs
        controller.should be_signed_in
      end
      
      it "should redirect to the user show page" do
        post "create", :user=>@attrs
        response.should redirect_to(user_path(assigns(:user)))
      end
      
      it "should have a welcome message" do
        post "create", :user=>@attrs
        flash[:success].should =~ /welcome/i
      end
    end
  end
end
