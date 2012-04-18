class LinksController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user, only: [:edit, :update, :destroy]

  def index
    @user = current_user
    @all_tags = Tag.all
    if params[:tag]
      # @links = Link.where(:user_id == @user.id).includes(:taggings)
      if @tag = Tag.find_by_name(params[:tag])
        @links = Link.includes(:taggings).where("links.user_id" => @user.id).where("taggings.tag_id" => @tag.id)
      else
        @links = @user.links        
      end
    else
      @links = @user.links
    end
  end
  
  def new
    @user = current_user  
    @link = Link.new
    @tags = Tag.all
    if params[:url]
      @url_value = params[:url]
    end
  end
  
  def create
    @tags = Tag.all
    if @url = Url.find_or_create_by_url(params[:link][:url])
      params[:link][:user_id] = current_user.id
      params[:link].delete(:url)
      tag_tmp = params[:link].delete(:tag)
      @link = Link.new(params[:link])
      @link.url = @url
      if @link.save
        new_tags = []
        @tags.each do |tag|
          if tag_tmp && tag_tmp[tag.id.to_s]
            new_tags << tag
          end
        end
        @link.tag_with(new_tags)
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
    @tags = Tag.all
    # @user = current_user  
    # @link = Link.find(params[:id])
  end
  
  def update
    if params[:link][:title] #normal edit form
      @tags = Tag.all
      # @user = current_user  
      # @link = Link.find(params[:id])
      @url = @link.url
      tag_tmp = params[:link].delete(:tag)
      params[:link][:stars] = 0 unless params[:link][:stars]
      if @link.update_attributes(params[:link])
        new_tags = []
        @tags.each do |tag|
          if tag_tmp && tag_tmp[tag.id.to_s]
            new_tags << tag
          end
        end
        @link.tag_with(new_tags)
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
        @tags = Tag.all
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
