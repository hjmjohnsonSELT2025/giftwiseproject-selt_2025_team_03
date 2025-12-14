class CreateAttendees < ActiveRecord::Migration[7.1]
  def change
    create_table :attendees do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 0

      t.timestamps
    end
    add_index :attendees, [:event_id, :user_id], unique: true
  end
end
