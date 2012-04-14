class LinksController < ApplicationController
  # before_filter :signed_in_user
  # before_filter :correct_user, only: [:edit, :update, :destroy]

  def index
    @user = current_user
    @links = @user.links
  end
  
  def new
    @user = current_user  
    @link = Link.new
  end
  
  def create
    if @url = Url.find_or_create_by_url(params[:link][:url])
      params[:link][:user_id] = current_user.id
      params[:link].delete(:url)
      @link = Link.new(params[:link])
      @link.url = @url
      if @link.save
        flash[:success] = "Link saved!"
        redirect_to links_path
      else
        render 'new'
      end
    else
      render 'new'
    end
  end
  
  def edit
    @user = current_user  
    @link = Link.find(params[:id])
  end
  
  def update
    @user = current_user  
    @link = Link.find(params[:id])
    @url = @link.url
    if @link.update_attributes(params[:link])
      flash[:success] = "Link updated"
      redirect_to links_path
    else
      render 'edit'
    end    
  end
  
  def destroy
    Link.find(params[:id]).destroy
    flash[:success] = "Link deleted."
    redirect_to links_path
  end
  
  # private
  # def correct_user
  #   @user = Link.find(params[:id]).user
  #   redirect_to(root_path) unless current_user?(@user)
  # end

  
end
