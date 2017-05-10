class Link < ApplicationRecord
  belongs_to :category

  validates_presence_of :title, :link_url
end
