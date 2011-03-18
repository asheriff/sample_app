require 'spec_helper'

describe "GlobalLinks" do
  before(:each) do
    @base_title = "My Silly Rials App"
  end
  
  %w(contact about help).each do |action|
    name = action.capitalize
    url = "/#{action}"
   
    it "should have a #{name} page at #{url}" do
      get url
      response.should have_selector("title",
        :content => "#{@base_title} :: #{name}"
      )
    end
  end
  
  it "should have a Home page at /" do
    get "/"
    response.should have_selector("title",
      :content => "#{@base_title} :: Home"
    )
  end
  
  it "should have a Sign Up page at /signup" do
    get "/signup"
    response.should have_selector("title",
      :content => "#{@base_title} :: Sign Up"
    )
  end
  
  it "should have the right links in the layout" do
    visit root_path
    
    click_link "Sign up now!"
    response.should have_selector("title",
      :content => "#{@base_title} :: Sign Up"
    )
    
    click_link "Home"
    response.should have_selector("title",
      :content => "#{@base_title} :: Home"
    )
    
    click_link "Help"
    response.should have_selector("title",
      :content => "#{@base_title} :: Help"
    )
    
    click_link "About"
    response.should have_selector("title",
      :content => "#{@base_title} :: About"
    )
    
    click_link "Contact"
    response.should have_selector("title",
      :content => "#{@base_title} :: Contact"
    )
  end
end
