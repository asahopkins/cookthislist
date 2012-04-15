class LinksController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user, only: [:edit, :update, :destroy]

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
    # @user = current_user  
    # @link = Link.find(params[:id])
  end
  
  def update
    if params[:link][:title] #normal edit form
      # @user = current_user  
      # @link = Link.find(params[:id])
      @url = @link.url
      params[:link][:stars] = 0 unless params[:link][:stars]
      if @link.update_attributes(params[:link])
        flash[:success] = "Link updated"
        redirect_to links_path
      else
        render 'edit'
      end
    else #stars only
      # @link = Link.find(params[:id])
      if @link.update_attributes(params[:link])
        # @message = "Stars updated"
        # @key = "success"
      else
        flash[:error] = "Stars NOT updated"
        # @user = current_user  
        @url = @link.url
        render 'edit'
      end
    end
  end
  
  def destroy
    Link.find(params[:id]).destroy
    flash[:success] = "Link deleted."
    redirect_to links_path
  end
  
  private
  
  def correct_user
    if Link.find(params[:id])
      @link = Link.find(params[:id])
      @user = @link.user
      redirect_to(root_path) unless current_user?(@user)
    else
      redirect_to(root_path)
    end
  end

  
end
