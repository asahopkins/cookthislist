FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  factory :url do
    sequence(:url)  { |n| "http://d#{n}.example.com/recipe.html"}
    sequence(:domain) { |n| "d#{n}.example.com"}
  end
  
  factory :link do
    stars 3
    sequence(:title)  { |n| "title_#{n}"}    
  end

end