class Tag < ActiveRecord::Base
  has_many :links, through: :taggings
  has_many :taggings
end
