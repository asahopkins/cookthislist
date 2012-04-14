class AddDefaultsToLinks < ActiveRecord::Migration
  def change
    change_column :links, :stars, :integer, :default=>0
  end
end
