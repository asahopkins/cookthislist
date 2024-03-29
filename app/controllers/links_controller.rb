class LinksController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user, only: [:edit, :update, :destroy]
  VALID_DOMAIN_REGEX = /^[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}$/i

  def index
    @user = current_user
    @all_tags = Tag.all
    if params[:sort] == "stars"
      order = "links.stars DESC, links.created_at DESC"
      star_filter = "links.stars < 6"
      @sort_by = "stars"
    elsif params[:sort] == "nostars"
      order = "links.created_at DESC"
      star_filter = "links.stars = 0"
      @sort_by = "nostars"
    else
      order = "links.created_at DESC"
      star_filter = "links.stars < 6"
      @sort_by = "date"
    end
    @links = Link.includes(:taggings).includes(:url).where("links.user_id" => @user.id)
    @rating_hash = {sort: "stars"}
    @date_hash = { }
    @nostar_hash = {sort: "nostars"}
    if params[:search]
      if params[:search].length >= 3
        @query = params[:search].to_s
        @links = @links.where(["lower(links.title) LIKE :query OR lower(links.notes) LIKE :query OR lower(urls.url) LIKE :query",{:query => "%#{@query.downcase}%"}])
        @rating_hash[:search] = @query.downcase
        @date_hash[:search] = @query.downcase
        @nostar_hash[:search] = @query.downcase
      else
        flash[:notice] = "Search terms must be at least 3 characters."
      end
    else
      if params[:tag]
        if tmp = Tag.find_by_name(params[:tag])
          @tag = tmp
          @links = @links.where("taggings.tag_id" => @tag.id)
          @rating_hash[:tag] = @tag.name
          @date_hash[:tag] = @tag.name
          @nostar_hash[:tag] = @tag.name
        end
      end
      if params[:source] =~ VALID_DOMAIN_REGEX
        @source = params[:source]
        @links = @links.where("urls.domain" => @source)
        @rating_hash[:source] = @source
        @date_hash[:source] = @source
        @nostar_hash[:source] = @source
      end
    end
    @links = @links.where(star_filter).order(order).paginate(page: params[:page])
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
