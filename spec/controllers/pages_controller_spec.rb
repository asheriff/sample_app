require 'spec_helper'

describe PagesController do
  render_views

  %w(home contact about).each do |action|
    describe "GET '#{action}'" do
      it "should be successful" do
        get action
        response.should be_success
      end
    end
  end
  
end
