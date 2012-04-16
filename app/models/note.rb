class Note < ActiveRecord::Base
  attr_accessible :title, :content

  belongs_to :notebook

  validates :title, :presence => true, :length => { :maximum => 50 }
  validates :notebook_id, :presence => true

  default_scope :order => 'notes.created_at DESC'
  
  private
    def within_notebook_uniqueness
      current_notebook = Notebook.find(notebook_id)
      if current_notebook.notes.find_by_title(title)
        errors.add(:title, "has already been taken by other note in this notebook") 
      end
    end
end
