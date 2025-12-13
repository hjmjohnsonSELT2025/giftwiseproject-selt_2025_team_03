class AddUniqueIndexToRecipientsOnUserIdAndName < ActiveRecord::Migration[7.1]
  def change
    add_index :recipients, [:user_id, :name], unique: true
  end
end
