require 'rails_helper'

RSpec.describe Fixture, type: :model do
  before(:all) do
    @team1 = create(:team)
    @team2 = create(:team)
  end

  it { should belong_to(:home_team) }
  it { should belong_to(:away_team) }

  describe "when fixture is valid" do
    it "is valid" do
      fixture = build(:fixture)
      expect(fixture).to be_valid
    end
  end

  describe "when fixture is invalid" do
    context "when home_team_id is invalid" do
      it "is invalid" do
        fixture = build(:fixture, home_team_id: nil, away_team_id: @team2.id)
        fixture.valid?
        expect(fixture.errors[:home_team]).to include('must exist')
      end
    end

    context "when away_team_id is invalid" do
      it "is invalid" do
        fixture = build(:fixture, home_team_id: @team1.id, away_team_id: nil)
        fixture.valid?
        expect(fixture.errors[:away_team]).to include('must exist')
      end
    end

    context "when home_team and away_team are the same" do
      it "is invalid" do
        fixture = build(:fixture, home_team_id: @team1.id, away_team_id: @team1.id)
        fixture.valid?
        expect(fixture.errors[:away_team]).to include("can't be the same as home_team")
      end
    end
  end
end
