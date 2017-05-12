class CategSerializer < ActiveModel::Serializer
  attributes :id, :name, :color, :lins_count

  has_many :lins
end
