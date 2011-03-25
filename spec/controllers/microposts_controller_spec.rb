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
        @attrs = { :content=>"" }
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
        @attrs = { :content=>"Lorem ipsum" }
      end
      
      it "should create a micropost" do
        lambda {
          post 'create', :micropost=>@attrs
        }.should change(Micropost, :count).by(1)
      end
      
      it "should redirect to the home page" do
        post 'create', :micropost=>@attrs
        response.should redirect_to(root_path)
      end
      
      it "should have a flash message" do
        post 'create', :micropost=>@attrs
        flash[:success].should =~ /created/i
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    describe "for an authorized user" do
      pending
    end
    
    describe "for a non-authorized user" do
      pending
    end
  end
end
  