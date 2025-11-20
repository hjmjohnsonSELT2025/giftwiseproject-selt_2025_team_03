class CreateRecipients < ActiveRecord::Migration[7.1]
  def change
    create_table :recipients do |t|
      t.integer :user_id, null: false
      t.string :name, null: false
      t.date :birthday
      t.string :relationship
      t.text :likes, default: "[]"
      t.text :dislikes, default: "[]"

      t.timestamps
    end

    add_index :recipients, :user_id
    add_foreign_key :recipients, :users
  end
end