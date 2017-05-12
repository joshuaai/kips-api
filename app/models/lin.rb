class Lin < ApplicationRecord
  belongs_to :categ, counter_cache: true

  validates_presence_of :title, :link_url
end
