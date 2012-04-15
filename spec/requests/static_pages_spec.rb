require 'spec_helper'

describe "Static pages" do

  subject { page }

  describe "Home page" do
    before { visit root_path }

    it { should have_selector('h1',    text: 'Cook This List') }
    it { should have_selector('title', text: full_title('')) }
    it { should_not have_selector 'title', text: '| Home' }

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:url1) { FactoryGirl.create(:url) }
      let(:url2) { FactoryGirl.create(:url) }
      let!(:l1) { FactoryGirl.create(:link, user: user, url: url1) }
      let!(:l2) { FactoryGirl.create(:link, user: user, url: url2) }
      before do
        sign_in user
        visit root_path
      end

      it "should render the user's list" do
        page.should have_selector("h4", text: l1.title)
      end

    end
  end

  describe "Help page" do
    before { visit help_path }

    it { should have_selector('h1',    text: 'Help') }
    it { should have_selector('title', text: full_title('Help')) }
  end

  describe "About page" do
    before { visit about_path }

    it { should have_selector('h1',    text: 'About') }
    it { should have_selector('title', text: full_title('About Us')) }
  end

  describe "Contact page" do
    before { visit contact_path }

    it { should have_selector('h1',    text: 'Contact') }
    it { should have_selector('title', text: full_title('Contact')) }
  end
end