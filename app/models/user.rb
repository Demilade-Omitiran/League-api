class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :validatable

  validates_presence_of :first_name, :last_name
  validates_presence_of :password, on: :create
end
