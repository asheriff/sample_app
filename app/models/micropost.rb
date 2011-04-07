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
  
  module Scopes
    def from_users_followed_by(user)
      post = Micropost.arel_table
      relationship = Relationship.arel_table
      
      followed_ids = relationship.where( relationship[:follower_id].eq( user.id) ).project( relationship[:followed_id] )
      
      where(
        post[:user_id].
          eq( user.id ).
          or( post[:recipient_id].eq( user.id )).
          or( post[:user_id].in( followed_ids )).
          or( post[:recipient_id].in( followed_ids ))
      )
    end
  end
  extend Scopes
  
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
end
