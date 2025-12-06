class AddPublicProfileToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :public_profile, :boolean
  end
end
