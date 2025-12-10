class AddLikesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :likes, :string
  end
end
