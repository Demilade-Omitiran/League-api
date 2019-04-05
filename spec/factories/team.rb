# spec/factories/team.rb
FactoryBot.define do
  factory :team do
    name { Faker::Football.unique.team }
  end
end