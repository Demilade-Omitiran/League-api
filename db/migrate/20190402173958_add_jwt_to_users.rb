class AddJwtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :valid_jwt, :string
  end
end
