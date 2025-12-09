class AddDislikesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :dislikes, :string
  end
end
