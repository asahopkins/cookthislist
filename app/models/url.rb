class Url < ActiveRecord::Base
  has_many :links
  
  before_save :create_domain
  
  VALID_URL_REGEX = /^http(s)?\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?$/i
  VALID_DOMAIN_REGEX = /^[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}$/i
  validates :url, presence: true, format: { with: VALID_URL_REGEX },
                    uniqueness: { case_sensitive: false }

    private
    
    def create_domain
      self.domain = self.url.split("/")[2]
    end
  
end
