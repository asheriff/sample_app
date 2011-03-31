require 'spec_helper'

describe RelationshipsController do
  describe "access control" do
    it "should require authentication for create" do
      post 'create'
      response.should redirect_to(signin_path)
    end
    
    it "should require authentication for destroy" do
      post 'destroy', :id=>1
      response.should redirect_to(signin_path)
    end
  end
  
  describe "POST 'create'" do
    before :each do
      @user = test_sign_in(Factory(:user))
      @followed = Factory(:user, :email=>Factory.next(:email))
    end
    
    it "should create a relationship" do
      lambda{
        post 'create', :relationship=>{ :followed_id=>@followed }
        response.should be_redirect
      }.should change(Relationship, :count).by(1)
    end
  end
  
  describe "DELETE 'destroy'" do
    before :each do
      @user = test_sign_in(Factory(:user))
      @followed = Factory(:user, :email=>Factory.next(:email))
      @user.follow!(@followed)
      @relationship = @user.relationships.find_by_followed_id( @followed )
    end
    
    it "should destroy a relationship" do
      lambda{
        post 'destroy', :id=>@relationship
        response.should be_redirect
      }.should change(Relationship, :count).by(-1)
    end
  end
end
