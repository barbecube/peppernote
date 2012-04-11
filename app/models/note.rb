class Note < ActiveRecord::Base
  attr_accessible :title, :content

  belongs_to :notebook

  validates :title, :presence => true, :length => { :maximum => 50 }
  validates :notebook_id, :presence => true

  default_scope :order => 'notes.created_at DESC'
end
