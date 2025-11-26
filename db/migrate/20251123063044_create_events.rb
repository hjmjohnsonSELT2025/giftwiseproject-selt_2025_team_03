class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :name
      t.date :date
      t.decimal :budget
      t.string :location
      t.string :theme
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
