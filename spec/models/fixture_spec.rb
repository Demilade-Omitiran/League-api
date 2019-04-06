require 'rails_helper'

RSpec.describe Fixture, type: :model do
  it { should validate_presence_of(:home_team_id) }
  it { should validate_presence_of(:away_team_id) }
  it { should validate_presence_of(:match_date) }
end
