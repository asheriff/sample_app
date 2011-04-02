# == Schema Information
# Schema version: 20110324212159
#
# Table name: microposts
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Micropost < ActiveRecord::Base
  attr_accessible :content
  
  belongs_to :user
  
  validates :content, :presence=>true, :length=>{ :maximum=>140 }
  validates :user_id, :presence=>true
  
  default_scope :order => "microposts.created_at DESC"
  
  def self.from_users_followed_by(user)
    ids = user.following.map{ |u| u.id } << user.id
    id_list = ids * ","
    where("user_id IN (#{id_list})")
  end
end
