require 'spec_helper'

describe Url do
  let(:user) { FactoryGirl.create(:user) }
  before do
    @url = Url.new(url: "http://smittenkitchen.com/2012/02/lasagna-bolognese/", 
                domain: "smittenkitchen.com")
    @link = user.links.build(stars: 3, notes: "This is really tasty", title: "Lasagna")
    @link.url = @url
  end
  subject { @url }

  it { should respond_to(:url) }
  it { should respond_to(:domain) }
  it { should respond_to(:links) }

  it { should be_valid }
  
  describe "when url is already taken" do
    before do
      url_with_same_url = @url.dup
      url_with_same_url.save
    end

    it { should_not be_valid }
  end
  
  describe "when url is already taken (case insensitive)" do
    before do
      url_with_same_url = @url.dup
      url_with_same_url.url[-3..0] = @url.url[-3..0].upcase
      url_with_same_url.save
    end

    it { should_not be_valid }
  end

  describe "when url is not well structured" do
    before { @url.url = "mailto:foo@example.com" }
    it { should_not be_valid }
  end

  describe "when saved with blank" do
    before do 
      @url.domain = "" 
      @url.save
    end
    
    its(:domain) { should == @url.url.split("/")[2] }
  end

end
