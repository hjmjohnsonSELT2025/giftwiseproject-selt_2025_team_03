class CreateEventInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :event_invitations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :inviter, null: false, foreign_key: { to_table: :users }
      t.references :invitee, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :event_invitations, [:event_id, :invitee_id], unique: true
  end
end
