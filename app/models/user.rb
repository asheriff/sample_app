# == Schema Information
# Schema version: 20110324051356
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean
#

require "digest"

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation
  
  has_many :microposts, :dependent=>:destroy
  has_many :relationships, :foreign_key=>:follower_id, :dependent=>:destroy
  has_many :reverse_relationships, :foreign_key=>:followed_id, :class_name=>"Relationship", :dependent=>:destroy
  has_many :following, :through=>:relationships, :source=>:followed
  has_many :followers, :through=>:reverse_relationships, :source=>:follower
  
  validates :name,
    :presence => true,
    :length => { :maximum=>50 },
    :format => /\A[-_a-z0-9]+\z/i,
    :uniqueness => { :case_sensitive => false }
  
  validates :email,
    :presence => true,
    :format => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
    :uniqueness => { :case_sensitive => false }
  
  validates :password,
    :presence => true,
    :confirmation => true,
    :length => { :within=>6..40 }
  
  strip_attributes! :only => [:name]
  
  before_save :encrypt_password
  
  # Returns the user if +email+ and +password are correct.
  #
  def self.authenticate(email, password)
    return nil unless user = find_by_email(email)
    return nil unless user.has_password?(password)
    user
  end
  
  # Returns the user if...
  #
  def self.authenticate_with_salt(id, salt)
    return nil unless user = find_by_id(id)
    return nil unless user.salt == salt
    user
  end
  
  # Returns true if +password+ matches user password.
  #
  def has_password?(password)
    encrypted_password == encrypt(password)
  end
  
  def email_md5
    Digest::MD5.hexdigest(email)
  end
  
  # Returns all posts by self + followed users.
  def feed
    Micropost.from_users_followed_by(self)
  end
  
  # Returns true if following +user+.
  #
  def following?(user)
    relationships.find_by_followed_id(user)
  end
  
  # Follow the +user+.
  #
  def follow!(user)
    relationships.create(:followed_id => user.id)
  end
  
  # Unfollow the +user+.
  #
  def unfollow!(user)
    relationships.find_by_followed_id(user.id).destroy
  end
  
  private
    
    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end
    
    def encrypt(s)
      secure_hash "#{salt}--#{s}"
    end
    
    def make_salt
      secure_hash "#{Time.now.utc}--#{password}"
    end
    
    def secure_hash(s)
      Digest::SHA2.hexdigest(s)
    end
end
