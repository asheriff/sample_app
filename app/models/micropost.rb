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
  attr_accessible :content, :recipient, :recipient_id, :extended_content
  # TODO: does making recipient and recipient_id exposes a security issue, ie.
  # could a user update posts to change the recipient?
  
  belongs_to :user
  belongs_to :recipient, :class_name=>"User"
  
  validates :content, :presence=>true, :length=>{ :maximum=>140 }
  validates :user_id, :presence=>true
  validate :valid_user_name_in_content
  validate :recipient_not_self
  
  strip_attributes! :only => [:content]
  
  default_scope :order => "microposts.created_at DESC"
  
  scope :from_users_followed_by, lambda { |user|
    followed_by(user)
  }
  
  # Set the content and recipient attributes from a string.
  #
  # Examples:
  #
  #    @username Rest of message
  #
  def extended_content=(s)
    # TODO: DRY: Use the User model regex for the useranme
    # TODO: use extended regex so this is human readable
    _, user_name, content = *s.match( /@([-_a-z0-9]+)(?:\s+(.*))?/i )
    user = user_name && User.find_by_name(user_name)
    
    if !user
      self[:content] = s
      self.recipient = nil if user_name
    else
      self[:content] = content
      self[:recipient_id] = user.id
    end
  end
  
  def extended_content
    if self.recipient
      "@#{self.recipient.name} #{self[:content]}"
    else
      self[:content]
    end
  end
  
  private
    def valid_user_name_in_content
      u = self[:content] && self[:content][/^@([-_a-z0-9]+)/,1]
      if !self.recipient && u
        errors.add :content, "contains a recipient @#{u} that doesn't exists"
      end
    end
    
    def recipient_not_self
      if self.recipient == self.user
        errors.add :recipient, "can't be your account"
      end
    end
    
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
end
