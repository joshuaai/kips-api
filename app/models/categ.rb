class Categ < ApplicationRecord
  has_many :lins, dependent: :destroy

  validates_presence_of :name, :color, :lins_count
end
