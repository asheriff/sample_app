require 'spec_helper'

describe Micropost do
  before :each do
    @user = Factory(:user)
    @attrs = { :content=>"micropost content" }
  end
  
  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attrs)
  end
  
  describe "user associations" do
    before :each do
      @micropost = @user.microposts.create(@attrs)
    end
    
    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end
    
    it "should have a recipient attribute" do
      @micropost.should respond_to(:recipient)
    end
    
    it "should have the correct associated user" do
      @micropost.user_id.should eq @user.id
      @micropost.user.should eq @user
    end
  end
  
  describe "recipient association" do
    before :each do
      @other_user = Factory(:user)
    end
    
    it "should have the correct associated recipient" do
      post = @user.microposts.create!(@attrs.merge(:recipient=>@other_user))
      post.recipient.should eq @other_user
    end
    
    describe "the #content= method" do
      describe "with valid @username" do
        it "should automatically set the recipient when content starts with @username" do
          content = "@#{@other_user.name} reply"
          post = @user.microposts.create!(:content=>content)
          post.recipient.should eq @other_user
        end
      end
      
      describe "with non-existant @username" do
        before :each do
          @content = "@nosuchuser reply"
          @post = @user.microposts.build(:content=>@content)
        end
        
        it "should be invalid" do
          @post.should_not be_valid
        end
        
        it "should have an error message describing the error" do
          @post.valid?
          @post.errors[:content].to_s.should =~ /The intended recipient @nosuchuser doesn't exists/
        end
        
        it "should still contain the non-existant @username" do
          @post.recipient.should be_nil
          @post.content.should == @content
        end
        
        it "should set recipient to nil if @username does not exists" do
          content = "@#{@other_user.name} reply"
          post = @user.microposts.build(:content=>content)
          post.recipient.should eq @other_user
          post.content = "@nosuchuser reply"
          post.recipient.should be_nil
        end
      end
      
      describe "with only a valid @username" do
        before :each do
          @content = "@#{@other_user.name}"
          @post = @user.microposts.build(:content=>@content)
        end
        
        it "should be invalid" do
          @post.should_not be_valid
        end
      end
    end
    
    describe "the #content method" do
      it "should have the recipient username in the content" do
        post = @user.microposts.create!(@attrs.merge(:recipient=>@other_user))
        post.content.should == "@#{@other_user.name} #{@attrs[:content]}"
      end
    end
  end
  
  describe "validations" do
    it "should require a user id" do
      Micropost.new(@attrs).should_not be_valid
    end
    
    it "should stript whitespace from content" do
      post = @user.microposts.create!(:content=>"   a   ")
      post.content.should == "a"
    end
    
    it "should not allow blank content" do
      @user.microposts.build(:content=>" ").should_not be_valid
    end
    
    it "should reject long content" do
      @user.microposts.build(:content=>"a"*141).should_not be_valid
    end
  end
  
  describe "self.from_users_followed_by" do
    before :each do
      @user_2 = Factory(:user, :email=>Factory.next(:email))
      @user_3 = Factory(:user, :email=>Factory.next(:email))
      
      @user_post = @user.microposts.create!( :content=>"foo" )
      @user_2_post = @user_2.microposts.create!( :content=>"bar" )
      @user_3_post = @user_3.microposts.create!( :content=>"baz" )
      
      @user.follow!( @user_2 )
    end
    
    it "should have a from_users_followed_by method" do
      Micropost.should respond_to(:from_users_followed_by)
    end
    
    it "should include the user's own microposts" do
      Micropost.from_users_followed_by(@user).should include(@user_post)
    end
    
    it "should include the followed user's microposts" do
      Micropost.from_users_followed_by(@user).should include(@user_2_post)
    end
    
    it "should not include the un-followed user's microposts" do
      Micropost.from_users_followed_by(@user).should_not include(@user_3_post)
    end
  end
end
