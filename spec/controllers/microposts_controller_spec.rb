require 'spec_helper'

describe MicropostsController do
  render_views
  
  describe "access control" do
    it "should deny access to 'create'" do
      post 'create'
      response.should redirect_to(signin_path)
    end
    
    it "should deny access to 'destroy'" do
      delete 'destroy', :id=>1
      response.should redirect_to(signin_path)
    end
  end
  
  describe "POST 'create'" do
    before :each do
      @user = test_sign_in(Factory(:user))
    end
    
    describe "failure" do
      before :each do
        @attrs = { :extended_content=>"" }
      end
      
      it "should not create a micropost" do
        lambda {
          post 'create', :micropost=>@attrs
        }.should_not change(Micropost, :count)
      end
      
      it "should render the home page" do
        post 'create', :micropost=>@attrs
        response.should render_template('pages/home')
      end
    end
    
    describe "success" do
      before :each do
        @attrs = { :extended_content=>"Lorem ipsum" }
      end
      
      it "should create a micropost" do
        lambda {
          post 'create', :micropost=>@attrs
        }.should change(Micropost, :count).by(1)
      end
      
      it "should have a flash message" do
        post 'create', :micropost=>@attrs
        flash[:success].should =~ /created/i
      end
      
      it "should redirect to the home page" do
        post 'create', :micropost=>@attrs
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe "POST 'create' with recipient" do
    before :each do
      @user = test_sign_in(Factory(:user))
      @other_user = Factory(:user, :email=>Factory.next(:email))
    end
    
    describe "failure" do
      describe "non-existent @username" do
        it "should not create a micropost" do
          lambda {
            post 'create', :micropost=>{:content=>"@nosuchuser Lorem ipsum"}
          }.should_not change(Micropost, :count)
        end
      end
      
      describe "no content" do
        it "should not create a micropost" do
          lambda {
            post 'create', :micropost=>{:content=>"@#{@other_user.name}    "}
          }.should_not change(Micropost, :count)
        end
      end
    end
    
    describe "success" do
      before :each do
        @extended_content = "@#{@other_user.name} Lorem ipsum"
      end
      
      it "should have a recipient if content starts with a valid @username" do
        lambda{
          post 'create', :micropost=>{:extended_content=>@extended_content}
        }.should change(Micropost, :count).by(1)
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    describe "for a non-authorized user" do
      before :each do
        @user = Factory(:user)
        @micropost = Factory(:micropost, :user=>@user)
        wrong_user = Factory(:user, :email=>Factory.next(:email))
        test_sign_in(wrong_user)
      end
      
      it "should deny access" do
        delete "destroy", :id=>@micropost
        response.should redirect_to(root_path)
      end
    end
    
    describe "for an authorized user" do
      before :each do
        @user = test_sign_in( Factory(:user) )
        @micropost = Factory(:micropost, :user=>@user)
      end
      
      it "should destroy the micropost" do
        lambda {
          delete "destroy", :id=>@micropost
        }.should change(Micropost, :count).by(-1)
      end
    end
  end
end
  