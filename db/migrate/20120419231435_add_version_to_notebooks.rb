class AddVersionToNotebooks < ActiveRecord::Migration
  def change
  	add_column :notebooks, :version, :integer, :default => 1
  end
end
