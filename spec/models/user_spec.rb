require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  describe "when user is valid" do
    it 'is valid' do
      user = build(:user)
    end
  end

  describe "when email is already taken" do
    it 'is not valid' do
      user1 = create(:user)
      user2 = build(:user, email: user1.email)
      user2.valid?
      expect(user2.errors[:email]).to include('has already been taken')
    end
  end
end
