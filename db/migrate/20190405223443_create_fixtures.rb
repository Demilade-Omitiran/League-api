class CreateFixtures < ActiveRecord::Migration[5.2]
  def change
    create_table :fixtures do |t|
      t.integer :home_team_id
      t.integer :away_team_id
      t.integer :home_team_goals
      t.integer :away_team_goals
      t.datetime :match_date

      t.timestamps
    end

    add_index :fixtures, [:home_team_id, :away_team_id], unique: true, name: :index_home_team_and_away_team
  end
end
