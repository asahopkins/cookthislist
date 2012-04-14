class Link < ActiveRecord::Base
  belongs_to :user
  belongs_to :url
  
  validate :stars_in_range
  validate :user_exists
  validate :url_exists
  validates :title, presence: true
  
  def stars_in_range
    if stars.blank? or stars < 0 or stars > 5
      errors.add(:stars, "must be between 0 and 5")
    end
  end
  
  def user_exists
    if user.nil?
      errors.add(:user_id, "must correspond to an actual user")
    end
  end
  
  def url_exists
    if url.nil? or url_id.nil?
      errors.add(:url_id, "must correspond to an actual url")
    end
  end

end
