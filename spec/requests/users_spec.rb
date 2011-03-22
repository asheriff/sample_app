require 'spec_helper'

describe "Users" do
  describe "create" do
    describe "failure" do
      it "should not create a new user" do
        lambda {
          visit signup_path
          fill_in "Name", :with=>""
          fill_in "Email", :with=>""
          fill_in "Password", :with=>""
          fill_in "Confirm", :with=>""
          click_button
          response.should render_template("users/new")
          response.should have_selector("#new_user .form_errors")
        }.should_not change(User, :count)
      end
    end
    
    describe "success" do
      it "should create a new user" do
        lambda {
          visit signup_path
          fill_in "Name", :with=>"New User"
          fill_in "Email", :with=>"foo@bar.com"
          fill_in "Password", :with=>"foobar"
          fill_in "Confirm", :with=>"foobar"
          click_button
          response.should render_template("users/show")
          response.should have_selector(".flash .message.success")
        }.should change(User, :count).by(1)
      end
    end
  end
  
  describe "signin/out" do
    describe "failure" do
      it "should not sign a user in and out" do
        visit signin_path
        fill_in "Email", :with=>""
        fill_in "Password", :with=>""
        click_button
        response.should have_selector(".flash .message.error")
      end
    end
    
    describe "success" do
      it "should not sign a user in and out" do
        user = Factory(:user)
        integration_sign_in(user)
        controller.should be_signed_in
        click_link "Sign Out"
        controller.should_not be_signed_in
      end
    end
  end
end
