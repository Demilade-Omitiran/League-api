# spec/factories/team.rb
FactoryBot.define do
  factory :team do
    name { Faker::Football.team + "_" + ((1..10000).to_a).sample.to_s }
  end
end