class LinksController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user, only: [:edit, :update, :destroy]

  def index
    @user = current_user
    @all_tags = Tag.all
    @tags = []
    @tag_names= []
    if params[:tags]
      params[:tags] = params[:tags].split("/")
      @links = Link.where(:user_id == @user.id).includes(:taggings)
      tag_ids = []
      params[:tags].each do |tag|
        if Tag.find_by_name(tag)
          tag_ids << Tag.find_by_name(tag).id 
          @tag_names << tag
          @tags << Tag.find_by_name(tag)
        end
      end
      @links = @links.where("taggings.tag_id" => tag_ids)
    else
      @links = @user.links
    end
  end
  
  def new
    @user = current_user  
    @link = Link.new
    @tags = Tag.all
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
