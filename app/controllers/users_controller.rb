class UsersController < ApplicationController
  before_filter :authenticate, :only => [
    :edit,
    :update,
  ]
  
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
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
  
  private
    
    def authenticate
      deny_access unless signed_in?
    end
end
