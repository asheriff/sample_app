module ApplicationHelper
  def title
    base_title = "My Silly Rials App"
    if @title && !@title.empty?
      "#{base_title} :: #{@title}"
    else
      base_title
    end
  end
end
