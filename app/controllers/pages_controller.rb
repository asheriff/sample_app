class PagesController < ApplicationController
  def home
    @micropost = Micropost.new if signed_in?
  end

  def contact
  end
  
  def about
  end
  
  def help
  end
end
