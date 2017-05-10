class CategorySerializer < ActiveModel::Serializer
  # attributes to be serialized
  attributes :id, :name, :color, :created_at, :updated_at
  # model association
  has_many :links
end
