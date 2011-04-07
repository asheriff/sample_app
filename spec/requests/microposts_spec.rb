require 'spec_helper'

describe "Microposts" do
  before :each do
    @other_user = Factory(:user, :email=>Factory.next(:email))
    
    user = Factory(:user)
    visit signin_path
    fill_in :email, :with=>user.email
    fill_in :password, :with=>user.password
    click_button
  end
  
  describe "creation" do
    describe "failure" do
      it "should not make a new micropost" do
        lambda {
          visit root_path
          fill_in :micropost_extended_content, :with=>""
          click_button
          response.should render_template("pages/home")
          response.should have_selector("#new_micropost .form_errors")
        }.should_not change(Micropost, :count)
      end
    end
    
    describe "success" do
      it "should make a new micropost" do
        content = "Foo bar baz"
        lambda {
          visit root_path
          fill_in :micropost_extended_content, :with=>content
          click_button
          response.should have_selector(".content", :content=>content)
        }.should change(Micropost, :count).by(1)
      end
      
      it "should make a new micropost with a recipient" do
        content = "@#{@other_user.name} Foo bar baz"
        lambda {
          visit root_path
          fill_in :micropost_extended_content, :with=>content
          click_button
          response.should have_selector(".content a",
            :content => "@#{@other_user.name}",
            :href => user_path(@other_user)
          )
        }.should change(Micropost, :count).by(1)
      end
      
    end
  end
end
