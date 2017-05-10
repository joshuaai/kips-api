class Category < ApplicationRecord
  belongs_to :user
  has_many :links, dependent: :destroy

  validates_presence_of :name, :color
end
