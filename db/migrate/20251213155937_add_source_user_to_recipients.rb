class AddSourceUserToRecipients < ActiveRecord::Migration[7.1]
  def change
    add_reference :recipients, :source_user, foreign_key: { to_table: :users }, null: true
  end
end
