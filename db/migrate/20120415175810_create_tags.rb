class CreateTags < ActiveRecord::Migration
  def up
    create_table :tags do |t|
      t.string :name
    end
    
    Tag.create name: "Breakfast"
    Tag.create name: "Lunch"
    Tag.create name: "Dinner"
    Tag.create name: "Sides"
    Tag.create name: "Desserts"
    Tag.create name: "Snacks"
    Tag.create name: "Drinks"
    
  end
  
  def down
    drop_table :tags
  end
end
