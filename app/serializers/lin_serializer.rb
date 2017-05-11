class LinSerializer < ActiveModel::Serializer
  attributes :id, :title, :link_url
  has_one :categ
end
