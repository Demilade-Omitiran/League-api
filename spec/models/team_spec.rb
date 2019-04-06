require 'rails_helper'

RSpec.describe Team, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should have_many(:home_fixtures) }
  it { should have_many(:away_fixtures) }

  describe 'when name is valid' do
    it 'is valid' do
      team = build(:team)
      expect(team).to be_valid
    end
  end

  describe 'when name is too short' do
    it 'is too short' do
      team = build(:team, name: 'abc')
      team.valid?
      expect(team.errors[:name]).to include('Enter a longer name')
    end
  end

  describe 'when name is too long' do
    it 'is too long' do
      long_name = "a" * 60
      team = build(:team, name: long_name)
      team.valid?
      expect(team.errors[:name]).to include('Enter a shorter name')
    end
  end
end
