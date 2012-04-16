class AddIndexToTaggings < ActiveRecord::Migration
  def change
    add_index :taggings, [:link_id, :tag_id], unique: true
  end
end
