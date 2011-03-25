class UsersController < ApplicationController
  before_filter :authenticate, :only => %w(index edit update destroy)
  before_filter :correct_user, :only => %w(edit update)
  before_filter :admin_user, :only => %w(destroy)
  before_filter :authenticated_user, :only => %w(new create)
  
  def index
    @users = User.paginate( :page=>params[:page] )
  end
  
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate( :page=>params[:page], :per_page=>10 )
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(params[:user])
    
    if @user.save
      sign_in(@user)
      flash[:success] = "Welcome to the sample app!"
      redirect_to(@user)
    else
      render :new
    end
  end
  
  def update
    @user = User.find(params[:id])
    
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to(@user)
    else
      render :edit
    end
  end
  
  def destroy
    user = User.find(params[:id])
    
    if user != current_user
      flash[:success] = "User destroyed: #{user.name}"
      user.destroy
    else
      flash[:notice] = "Cannot destroy self: #{user.name}"
    end
    
    redirect_to(users_path)
  end
  
  private
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
    
    def authenticated_user
      redirect_to(root_path) if signed_in?
    end
end
