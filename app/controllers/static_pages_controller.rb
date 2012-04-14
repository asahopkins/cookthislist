class StaticPagesController < ApplicationController
  def home
    if signed_in?
      redirect_to links_path
    end
  end

  def help
  end

  def about
  end

  def contact
  end

end
