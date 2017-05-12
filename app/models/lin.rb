class Lin < ApplicationRecord
  belongs_to :categ, counter_cache: :lins_count

  validates_presence_of :title, :link_url
end
