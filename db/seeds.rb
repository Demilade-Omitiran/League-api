# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(first_name: "admin", last_name: "league", email: "admin@league.com", admin: true, password: "password")

10.times do
  name1 = Faker::Football.team + "_" + ((1..10000).to_a).sample.to_s
  name2 = Faker::Football.team + "_" + ((1..10000).to_a).sample.to_s

  team1 = Team.create(name: name1)
  team2 = Team.create(name: name2)

  random_time = Faker::Date.between(3.weeks.ago, 3.weeks.ago)
  
  fixture_create_hash = { home_team_id: team1.id, away_team_id: team2.id, match_date: random_time }

  if random_time.past?
    fixture_create_hash[:home_team_goals] = (1..5).to_a.sample
    fixture_create_hash[:away_team_goals] = (1..5).to_a.sample
  end

  Fixture.create(fixture_create_hash)
end

