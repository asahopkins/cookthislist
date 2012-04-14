require 'spec_helper'

describe Link do
  let(:user) { FactoryGirl.create(:user) }
  before do
    user.save
    @url = Url.new(url: "http://smittenkitchen.com/2012/02/lasagna-bolognese/", 
                      domain:"smittenkitchen.com")
    @url.save
    @link = Link.new(stars: 3, notes: "This is really tasty", 
                     title: "Lasagna")
    @link.user = user
    @link.url = @url
    # puts @link.url_id
    # puts @url.id
  end

  subject { @link }

  it { should respond_to(:stars) }
  it { should respond_to(:notes) }
  it { should respond_to(:title) }
  it { should respond_to(:url) }
  it { should respond_to(:user) }

  it { should be_valid }
  
  describe "when stars is out of range" do
    before { @link.stars = 6 }
    it { should_not be_valid }
  end
    
  describe "when stars is blank" do
    before { @link.stars = nil }
    it { should_not be_valid }
  end
  
  describe "when title is blank" do
    before { @link.title = "" }
    it { should_not be_valid }
  end
  
  describe "when title is blank" do
    before { @link.title = nil }
    it { should_not be_valid }
  end
  
  describe "when there is no user" do
    before { @link.user_id = 1700 }
    it { should_not be_valid }
  end

  describe "when there is no url" do
    before { @link.url_id = 1700 }
    it { should_not be_valid }
  end

end
