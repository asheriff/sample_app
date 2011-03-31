require 'spec_helper'

describe UsersController do
  render_views
  
  before(:each) do
    @base_title = "My Silly Rials App"
  end
  
  describe "GET 'index'" do
    describe "for non-authenticated users" do
      it "should deny access" do
        get "index"
        response.should redirect_to(signin_path)
      end
    end
    
    describe "for authenticated users" do
      before :each do
        @pagination_count = 30
        @user = test_sign_in(Factory(:user))
        @users = [@user]
        
        30.times do
          @users << Factory( :user, :email=>Factory.next(:email) )
        end
      end
      
      it "should be successful" do
        get "index"
        response.should be_success
      end
      
      it "should have the right title" do
        get "index"
        response.should have_selector("title",
          :content => "#{@base_title} :: All Users"
        )
      end
      
      it "should have an element for each user" do
        get "index"
        @users.each do |user|
          response.should have_selector("li",
            :content => user.name
          )
        end
      end
      
      it "should paginate user list" do
        get "index"
        response.should have_selector(".pagination")
        response.should have_selector(".pagination .disabled")
        response.should have_selector("a", 
          :href => "/users?page=2",
          :content => "2"
        )
      end
      
      describe "without admin privleges" do
        it "should not have a delete link for any users" do
          get "index"
          response.should_not have_selector(".users a",
            :rel => "nofollow",
            :"data-method" => "delete"
          )
        end
      end
      
      describe "with admin privleges" do
        before :each do
          @user.toggle!(:admin)
        end
        
        it "should have a delete link for each user except self" do
          get "index"
          
          # Make sure the default GET link to /user/:id is there and
          # not on a subsequent page in the pagination
          response.should have_selector(".users a",
            :href => user_path(@user)
          )
          
          @users.first(@pagination_count).each do |user|
            next if user = @user
            response.should have_selector(".users a",
              :href => user_path(user),
              :rel => "nofollow",
              :"data-method" => "delete"
            )
          end
        end
      end
    end
  end

  describe "GET 'new'" do
    describe "as a non-authenticated user" do
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
    
    describe "as a authenticated user" do
      before :each do
        @user = Factory(:user)
        test_sign_in(@user)
      end
      
      it "should redirect to home page" do
        get 'new'
        response.should redirect_to(root_path)
      end
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
    
    it "should show the user's micropost" do
      posts = []
      3.times do |n|
        posts << Factory(:micropost, :user=>@user, :content=>"Post #{n}")
      end
      
      get :show, :id=>@user
      posts.each do |post|
        response.should have_selector(".content", :content=>post.content )
      end
    end
  end
  
  describe "POST 'create'" do
    describe "as a authenticated user" do
      before :each do
        @user = Factory(:user)
        test_sign_in(@user)
        @attrs = { :name=>"New User", :email=>"user@foo.com", :password=>"foobar", :password_confirmation=>"foobar" }
      end
      
      it "should not create a user" do
        lambda {
          post "create", :user=>@attrs
        }.should_not change(User, :count)
      end
      
      it "should redirect to home page" do
        post "create", :user=>@attrs
        response.should redirect_to(root_path)
      end
    end
    
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

  describe "GET 'edit'" do
    before :each do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get 'edit', :id => @user
      response.should be_success
    end
    
    it "should have the correct title" do
      get 'edit', :id => @user
      response.should have_selector("title",
        :content => "#{@base_title} :: #{@user.name} :: Edit"
      )
    end
    
    it "should have a link to change gravatar" do
      get 'edit', :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a",
        :href => gravatar_url,
        :content => "Change"
      )
    end
  end
  
  describe "PUT 'update'" do
    before :each do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    describe "failure" do
      before :each do
        @attrs = { :name=>"", :email=>"", :password=>"", :password_confirmation=>"" }
      end
      
      it "should render the edit page" do
        put "update", :id=>@user, :user=>@attrs
        response.should render_template("edit")
      end
      
      it "should have the correct title" do
        put "update", :id=>@user, :user=>@attrs
        response.should have_selector("title",
          :content => "#{@base_title} :: #{@attrs[:name]} :: Edit"
        )
      end
    end
    
    describe "success" do
      before :each do
        @attrs = { :name=>"New Name", :email=>"new@new.com", :password=>"newpass", :password_confirmation=>"newpass" }
      end
      
      it "should change teh user's attributes" do
        put "update", :id=>@user, :user=>@attrs
        @user.reload
        @user.name.should eq @attrs[:name]
        @user.email.should eq @attrs[:email]
      end
      
      it "should redirect to the show user screen" do
        put "update", :id=>@user, :user=>@attrs
        response.should redirect_to(user_path(@user))
      end
      
      it "should have a flash message" do
        put "update", :id=>@user, :user=>@attrs
        flash[:success].should =~ /updated/i
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    before :each do
      @user = Factory(:user)
    end
    
    describe "as a non-authenticated user" do
      it "should deny access" do
        delete "destroy", :id=>@user
        response.should redirect_to(signin_path)
      end
    end
    
    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete "destroy", :id=>@user
        response.should redirect_to(root_path)
      end
    end
    
    describe "as a admin user" do
      before :each do
        @admin = Factory(:user, :email=>"admin@example.com", :admin=>true)
        test_sign_in(@admin)
      end
      
      it "should destroy the user" do
        lambda{
          delete "destroy", :id=>@user
        }.should change(User, :count).by(-1)
      end
      
      it "should redirect to the users page" do
        delete "destroy", :id=>@user
        response.should redirect_to(users_path)
      end
      
      it "should not be able to delete self" do
        lambda{
          delete "destroy", :id=>@admin
        }.should_not change(User, :count)
      end
    end
  end
  
  describe "authentication for edit/update screens" do
    before :each do
      @user = Factory(:user)
    end
    
    describe "for non-authenticated users" do
      it "should deny accss to 'edit'" do
        get "edit", :id=>@user
        response.should redirect_to(signin_path)
      end
      
      it "should deny accss to 'update'" do
        put "update", :id=>@user, :user=>{}
        response.should redirect_to(signin_path)
      end
    end
    
    describe "for authenticated users" do
      before :each do
        wrong_user = Factory(:user, :email=>"user@example.net")
        test_sign_in(wrong_user)
      end
      
      it "should require matching users for 'edit'" do
        get "edit", :id=>@user
        response.should redirect_to(root_path)
      end
      
      it "should require matching users for 'update'" do
        put "update", :id=>@user, :user=>{}
        response.should redirect_to(root_path)
      end
    end
  end
end
