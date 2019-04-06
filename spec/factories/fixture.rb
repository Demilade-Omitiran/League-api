# spec/factories/fixture.rb
FactoryBot.define do
  factory :fixture do
    home_team { create(:team) }
    away_team { create(:team) }
    match_date { DateTime.now + 1.day }
  end
end