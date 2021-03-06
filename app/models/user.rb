class User < ApplicationRecord
  has_many :categories
  # encrypt password
  has_secure_password

  # Validations
  validates_presence_of :name, :email, :password_digest
end
