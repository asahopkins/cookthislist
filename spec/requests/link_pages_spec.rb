require 'spec_helper'

describe "Link pages" do

  let(:user) { FactoryGirl.create(:user) }
  let(:url1) { FactoryGirl.create(:url) }
  let(:url2) { FactoryGirl.create(:url) }
  let!(:l1) { FactoryGirl.create(:link, user: user, url: url1) }
  let!(:l2) { FactoryGirl.create(:link, user: user, url: url2) }
  before do
    user.save
    url1.save
    url2.save
    l1.save
    l2.save
  end

  subject { page }
  
  describe "list/index page" do
    before do
      sign_in user
      visit links_path
    end
    
    it { should have_selector('title', text: user.name) }

    it { should have_link(l1.title, href: l1.url.url) }
    it { should have_link(l2.title, href: l2.url.url) }
    
    it { should have_link("Add Link", href: new_link_path) }
    it { should have_link("", href: edit_link_path(l1)) }
    it { should have_link("", href: link_path(l1)) }
    it { should have_link("", href: edit_link_path(l2)) }
    it { should have_link("", href: link_path(l2)) }
    
  end
  
  describe "new link page" do
    before do
      sign_in user
      visit new_link_path
    end
    it { should have_selector('title', text: "New link") }
    it { should have_selector('h1',    text: 'New link') }    
  end
  
  describe "new link process" do
    before do
      sign_in user
      visit new_link_path
    end

    describe "with invalid information" do
      it "should not create a link" do
        expect { click_button "Create link" }.not_to change(Link, :count)
      end
      
      describe "error messages" do
        before { click_button "Create link" }

        it { should have_selector('title', text: 'New link') }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before do
        fill_in "Url", with: "http://smittenkitchen.com/2012/02/lasagna-bolognese/"
        fill_in "Title", with: "Lasagna"
        choose('star_3')
        fill_in "Notes", with: "note"
      end
      
      it "should create a link" do
        expect do
          click_button "Create link"
        end.to change(Link, :count).by(1)
      end
      
      describe "after saving the link" do
        before { click_button "Create link" }
        let(:link) { Link.find_by_title('Lasagna') }

        it { should have_selector('h4', text: link.title) }
        it { should have_selector('div.alert.alert-success', text: 'Link saved!') }
      end
      
    end

  end
  
  describe "edit link page" do
    before do
      sign_in user
      visit edit_link_path(l1)
    end
    it { should have_selector('title', text: "Edit link") }
    it { should have_selector('h1',    text: 'Edit link') }    
  end
  
  describe "edit link process" do
    before do
      sign_in user
      visit edit_link_path(l1)
    end
    # describe "with invalid information" do
    #   before do
    #     fill_in "Stars", with: "6" #with fancy stars, it's no longer possible to create an invalid link
    #   end
    #   it "should not update number of links" do
    #     expect { click_button "Update link" }.not_to change(Link, :count)
    #   end
    #   describe "error messages" do
    #     before { click_button "Update link" }
    # 
    #     it { should have_selector('title', text: 'Edit link') }
    #     it { should have_content('error') }
    #   end
    # end

    describe "with valid information" do
      before do
        fill_in "Title", with: "new title"
      end
      
      it "should not update number of links" do
        expect { click_button "Update link" }.not_to change(Link, :count)
      end
      
      describe "after saving the link" do
        before { click_button "Update link" }
        it { should have_selector('h4', text: "new title") }
        it { should have_selector('div.alert.alert-success', text: 'Link updated') }
      end
      
    end
    
  end
  
  describe "destroy link process" do 
    before do
      sign_in user
      visit links_path
    end
    it "should destroy a link" do
      expect do
        delete link_path(l1)
      end.to change(Link, :count).by(-1)
    end
  end
  
end