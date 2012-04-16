class Link < ActiveRecord::Base
  attr_accessible :stars, :title, :notes, :user_id, :url_id
  belongs_to :user
  belongs_to :url
  has_many :tags, through: :taggings
  has_many :taggings
  
  validate :stars_in_range
  validate :user_exists
  validate :url_exists
  validates :title, presence: true
  
  # scope :tagged_with, lambda { |tag_id| {:conditions => {"taggings.tag_id" => tag_id}, :include=>:taggings } }
  # 
  
  def tag_with(new_tags)
    self.taggings.each do |tagging|
      tagging.delete
    end
    new_tags.each do |tag|
      self.tags << tag
    end
  end
  
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
