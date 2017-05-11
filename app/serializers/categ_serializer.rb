class CategSerializer < ActiveModel::Serializer
  attributes :id, :name, :color

  has_many :lins
end
