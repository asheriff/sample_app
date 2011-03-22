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
end
