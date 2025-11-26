class CreateGiftIdeas < ActiveRecord::Migration[7.1]
  def change
    create_table :gift_ideas do |t|
      t.string :title
      t.decimal :price
      t.string :status
      t.string :url
      t.text :notes
      t.references :event_recipient, null: false, foreign_key: true

      t.timestamps
    end
  end
end
