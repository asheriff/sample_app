module UsersHelper
  def gravatar_url(user, options={})
    opts = {
      :size => 50,
      :default => :identicon,
    }.merge(options)
    
    src = "http://www.gravatar.com/avatar/#{@user.email_md5}?" +
     opts.collect{ |k,v| "#{k}=#{v}"}.join("&")
  end
end
