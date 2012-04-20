require 'spec_helper'

describe "Link pages" do
  fixtures :tags

  let(:user) { FactoryGirl.create(:user) }
  let(:url1) { FactoryGirl.create(:url) }
  let(:url2) { FactoryGirl.create(:url) }
  let(:url4) { FactoryGirl.create(:url) }
  let!(:l1) { FactoryGirl.create(:link, user: user, url: url1) }
  let!(:l2) { FactoryGirl.create(:link, user: user, url: url2) }
  let!(:l4) { FactoryGirl.create(:link, user: user, url: url4) } # l4 has 0 tags
  before do
    l1.tags << Tag.find(1) # l1 has one tag
    l2.tags << Tag.find(2) # l2 has two tags
    l2.tags << Tag.find(5)
    user.save
    url1.save
    url2.save
    l1.save
    l2.save
    l4.save
  end
  
  after(:all) do
    Link.delete_all
    Url.delete_all
    User.delete_all
  end

  subject { page }
  
  describe "list/index page" do
    before do
      sign_in user
      visit links_path
    end
    
    # it { should have_selector('title', text: user.name) }
    # 
    # it { should have_link(l1.title, href: l1.url.url) }
    # it { should have_link(l1.url.domain) }
    # it { should have_link(l2.title, href: l2.url.url) }
    # it { should have_link(l4.title, href: l4.url.url) }
    # 
    # it { should have_link("Add Link", href: new_link_path) }
    # it { should have_link("", href: edit_link_path(l1)) }
    # it { should have_link("", href: link_path(l1)) }
    # it { should have_link("", href: edit_link_path(l2)) }
    # it { should have_link("", href: link_path(l2)) }
    
    describe "with one tag filter" do
      before { visit links_path
        click_link "Breakfast"
         }
      it { should have_link(l1.title, href: l1.url.url) }
      it { should_not have_link(l2.title, href: l2.url.url) }
      it { should_not have_link(l4.title, href: l4.url.url) }
    end
    describe "with one and then another tag filters" do
      before do
        visit links_path
        click_link "Breakfast"
        click_link "Desserts"
      end
      it { should_not have_link(l1.title, href: l1.url.url) }
      it { should have_link(l2.title, href: l2.url.url) }
      it { should_not have_link(l4.title, href: l4.url.url) }   
    end
    describe "back to un-filtered after two" do
      before do
        visit links_path
        click_link "Breakfast"
        click_link "Desserts"
        click_link "Desserts"
      end
      it { should have_link(l1.title, href: l1.url.url) }
      it { should have_link(l2.title, href: l2.url.url) }
      it { should have_link(l4.title, href: l4.url.url) }
    end
    
    describe "pagination" do 
      before(:all) do
        35.times do
          FactoryGirl.create(:url)
          url = Url.last
          FactoryGirl.create(:link, user: user, url: url)
        end
      end
      after(:all) do 
        Link.delete_all
        Url.delete_all
        User.delete_all
      end

      let(:first_page)  { user.links.order("links.created_at DESC").page(1) }
      let(:second_page) { user.links.order("links.created_at DESC").page(2) }

      it { should have_link('Next') }
      it { should have_link('2') }
      
      it "should list the first page of links" do
        first_page.each do |link|
          page.should have_link(link.title, href: link.url.url)
        end
      end

      it "should not list the second page of links" do
        second_page.each do |link|
          page.should_not have_link(link.title, href: link.url.url)
        end
      end

      describe "showing the second page" do
        before { visit links_path(page: 2) }

        it "should list the second page of links" do
          second_page.each do |link|
            page.should have_link(link.title, href: link.url.url)
          end
        end
      end
    end

    describe "sorting" do
      before(:all) do
        35.times do
          FactoryGirl.create(:url)
          url = Url.last
          FactoryGirl.create(:link, user: user, url: url)
        end
        l1.stars = 5
        l1.save
        l4.stars = 0
        l4.save
      end
      after(:all) do 
        Link.delete_all
        Url.delete_all
        User.delete_all
      end
      before do
        visit links_path
        click_link "Rating"        
      end
      it { should have_link("Rating", href: links_path(sort: "stars")) }
      it { should have_link("Date added", href: links_path) }
      describe "by stars" do
        it "should list the most stars first" do
          page.should have_link(l1.title, href: l1.url.url)
          page.should_not have_link(l4.title, href: l4.url.url)
        end
        describe "second page of sorted list" do
          before { click_link "2" }
          it "should list the least stars last" do
            page.should_not have_link(l1.title, href: l1.url.url)
            page.should have_link(l4.title, href: l4.url.url)
          end
        end
      end
      describe "by date" do
        let(:old_link) { user.links.order("created_at DESC").last }
        let(:new_link) { user.links.order("created_at DESC").first }
        before do 
          click_link "Date added"
        end
        it "should list the newest links first" do
          page.should have_link(new_link.title, href: new_link.url.url)
          page.should_not have_link(old_link.title, href: old_link.url.url)
        end
        describe "second page of sorted list" do
          before { click_link "2" }
          it "should list the oldest links last" do
            page.should_not have_link(new_link.title, href: new_link.url.url)
            page.should have_link(old_link.title, href: old_link.url.url)
          end
        end        
      end
    end
    
    describe "filtering" do
      it { should have_link("No stars", href: links_path(sort: "nostars")) }
      describe "by no stars" do
        before do 
          l1.stars = 5
          l1.save
          l4.stars = 0
          l4.save
          visit links_path
          click_link "No stars"
        end
        it { should_not have_link(l1.title, href: l1.url.url) }
        it { should have_link(l4.title, href: l4.url.url) }
      end
      
      describe "by source site" do
        before do 
          visit links_path
        end
        it { should have_link(l1.url.domain) }
        it { should have_link(l1.url.domain, href: links_path(source: l1.url.domain)) }
        before do 
          visit links_path(source: l1.url.domain)
        end
        it { should have_link(l1.title, href: l1.url.url) }
        it { should_not have_link(l2.title) }
      end
    end
    
  end
    
  # describe "new link page" do
  #   before do
  #     sign_in user
  #     visit new_link_path
  #   end
  #   it { should have_selector('title', text: "New link") }
  #   it { should have_selector('h1',    text: 'New link') }    
  # end
  # 
  # describe "new link process" do
  #   before do
  #     sign_in user
  #     visit new_link_path
  #   end
  # 
  #   describe "with invalid information" do
  #     it "should not create a link" do
  #       expect { click_button "Create link" }.not_to change(Link, :count)
  #     end
  #     
  #     describe "error messages" do
  #       before { click_button "Create link" }
  # 
  #       it { should have_selector('title', text: 'New link') }
  #       it { should have_content('error') }
  #     end
  #   end
  # 
  #   describe "with valid information" do
  #     before do
  #       fill_in "Url", with: "http://smittenkitchen.com/2012/02/lasagna-bolognese/"
  #       fill_in "Title", with: "Lasagna"
  #       choose('star_3')
  #       fill_in "Notes", with: "note"
  #       check('tag_3')
  #     end
  #     
  #     it "should create a link" do
  #       expect do
  #         click_button "Create link"
  #       end.to change(Link, :count).by(1)
  #     end
  #     
  #     describe "after saving the link" do
  #       before { click_button "Create link" }
  #       let(:link) { Link.find_by_title('Lasagna') }
  # 
  #       it { should have_selector('h4', text: link.title) }
  #       it { should have_selector('div.alert.alert-success', text: 'Link saved!') }
  #     end
  #     
  #     describe "after saving the link and checking tags" do
  #       before { click_button "Create link" 
  #         click_link "Dinner"
  #         }
  #       let(:link) { Link.find_by_title('Lasagna') }
  #       it { should have_selector('h4', text: link.title) }
  #     end
  # 
  #     describe "after saving the link and checking other tag" do
  #       before { click_button "Create link" 
  #         click_link "Breakfast"
  #         }
  #       let(:link) { Link.find_by_title('Lasagna') }
  #       it { should_not have_selector('h4', text: link.title) }
  #     end
  #   end
  # 
  # end
  # 
  # describe "edit link page" do
  #   before do
  #     sign_in user
  #     visit edit_link_path(l1)
  #   end
  #   it { should have_selector('title', text: "Edit link") }
  #   it { should have_selector('h1',    text: 'Edit link') }    
  # end
  # 
  # describe "edit link process" do
  #   before do
  #     sign_in user
  #     visit edit_link_path(l1)
  #   end
  #   # describe "with invalid information" do
  #   #   before do
  #   #     fill_in "Stars", with: "6" #with fancy stars, it's no longer possible to create an invalid link
  #   #   end
  #   #   it "should not update number of links" do
  #   #     expect { click_button "Update link" }.not_to change(Link, :count)
  #   #   end
  #   #   describe "error messages" do
  #   #     before { click_button "Update link" }
  #   # 
  #   #     it { should have_selector('title', text: 'Edit link') }
  #   #     it { should have_content('error') }
  #   #   end
  #   # end
  # 
  #   describe "with valid information" do
  #     before do
  #       fill_in "Title", with: "new title"
  #       uncheck('tag_1')
  #       check('tag_3')
  #     end
  #     
  #     it "should not update number of links" do
  #       expect { click_button "Update link" }.not_to change(Link, :count)
  #     end
  #     
  #     describe "after saving the link" do
  #       before { click_button "Update link" }
  #       it { should have_selector('h4', text: "new title") }
  #       it { should have_selector('div.alert.alert-success', text: 'Link updated') }
  #     end
  #     
  #     describe "after saving the link and checking tags" do
  #       before { click_button "Update link" 
  #         click_link "Dinner"
  #         }
  #       it { should have_selector('h4', text: "new title") }
  #     end
  # 
  #     describe "after saving the link and checking other tag" do
  #       before { click_button "Update link" 
  #         click_link "Breakfast"
  #         }
  #       it { should_not have_selector('h4', text: "new title") }
  #     end
  #   end
  #   
  # end
  # 
  # describe "destroy link process" do 
  #   before do
  #     sign_in user
  #     visit links_path
  #   end
  #   it "should destroy a link" do
  #     expect do
  #       delete link_path(l1)
  #     end.to change(Link, :count).by(-1)
  #   end
  # end
  # 
  # describe "index page without sign-in" do
  #   before do
  #     visit links_path
  #   end
  #   it { should have_selector('h1',    text: 'Sign in') }
  # end
  # 
  # describe "new page without sign-in" do
  #   before do
  #     visit new_link_path
  #   end
  #   it { should have_selector('h1',    text: 'Sign in') }
  # end
  # 
  # describe "edit page without sign-in" do
  #   before do
  #     visit edit_link_path(l1)
  #   end
  #   it { should have_selector('h1',    text: 'Sign in') }
  # end
  # 
  # describe "edit page signed in as wrong user" do
  #   let(:user2) { FactoryGirl.create(:user) }
  #   let(:url3) { FactoryGirl.create(:url) }
  #   let!(:l3) { FactoryGirl.create(:link, user: user2, url: url3) }
  #   before do
  #     sign_in user
  #     visit edit_link_path(l3)
  #   end
  #   it { should have_selector('title', text: user.name) }
  #   it { should have_link(l1.title, href: l1.url.url) }
  #   it { should have_link(l2.title, href: l2.url.url) }
  # end
  
end