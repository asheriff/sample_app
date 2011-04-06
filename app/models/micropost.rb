# == Schema Information
# Schema version: 20110405163857
#
# Table name: microposts
#
#  id           :integer         not null, primary key
#  content      :string(255)
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#  recipient_id :integer
#

class Micropost < ActiveRecord::Base
  attr_accessible :content, :recipient, :recipient_id
  # TODO: does making recipient and recipient_id exposes a security issue, ie.
  # could a user update posts to change the recipient?
  
  belongs_to :user
  belongs_to :recipient, :class_name=>"User"
  
  validates :content, :presence=>true, :length=>{ :maximum=>140 }
  validates :user_id, :presence=>true
  
  strip_attributes! :only => [:content]
  
  default_scope :order => "microposts.created_at DESC"
  
  scope :from_users_followed_by, lambda { |user|
    followed_by(user)
  }
  
  before_validation :parse_user_name_from_content
  
  private
    
    def self.followed_by(user)
      params = { :user_id => user.id  }
      
      sql = %(
        user_id IN (
          SELECT followed_id
          FROM relationships
          WHERE follower_id = :user_id
        ) OR user_id = :user_id
      )
      
      where( sql , params )
    end
    
    def parse_user_name_from_content
      # TODO: DRY: Use the User model regex for the useranme
      return unless attribute_present?(:content)
      
      _, user_name, content = *self.content.match( /@([-_a-z0-9]+)(?:\s+(.*))?/i )
      
      if user_name
        self.recipient = User.find_by_name(user_name)
        self.content = content
      end
    end
end
