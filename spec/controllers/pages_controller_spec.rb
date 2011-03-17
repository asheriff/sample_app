require 'spec_helper'

describe PagesController do
  render_views
  
  before(:each) do
    @base_title = "My Silly Rials App"
  end

  %w(home contact about help).each do |action|
    describe "GET '#{action}'" do
      it "should be successful" do
        get action
        response.should be_success
      end
      
      it "should have the correct title" do
        get action
        response.should have_selector("title",
          :content => "#{@base_title} :: #{action.capitalize}"
        )
      end
    end
  end
  
end
