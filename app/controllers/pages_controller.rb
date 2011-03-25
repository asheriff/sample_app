class PagesController < ApplicationController
  def home
    if signed_in?
      @micropost = Micropost.new if signed_in?
      @feed_items = current_user.feed.paginate( :page=>params[:page], :per_page=>10 )
    end
  end

  def contact
  end
  
  def about
  end
  
  def help
  end
end
