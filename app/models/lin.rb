class Lin < ApplicationRecord
  belongs_to :categ

  validates_presence_of :title, :link_url
end
