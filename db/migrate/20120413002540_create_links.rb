class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :stars
      t.text :notes
      t.string :title
      t.integer :user_id
      t.integer :url_id

      t.timestamps
    end
  end
end
