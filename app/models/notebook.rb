class Notebook < ActiveRecord::Base
  attr_accessible :name

  belongs_to :user
  has_many :notes, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 50 }
  validates :user_id, :presence => true

  default_scope :order => 'notebooks.created_at DESC'  
end
