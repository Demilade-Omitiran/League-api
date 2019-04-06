class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :validatable

  validates_presence_of :first_name, :last_name
  validates_presence_of :password, on: :create

  after_save :create_json_cache

  def self.cache_key(users)
    {
      serializer: 'users',
      stat_record: users.maximum(:updated_at)
    }
  end

  private

  def create_json_cache
    users = Rails.cache.fetch('users') do
      User.paginate(page: 1, per_page: 20)
    end
  end
end
