class AddVersionToNotes < ActiveRecord::Migration
  def change
  	add_column :notes, :version, :integer, :default => 1
  end
end
