class AddConstraintsToUsers < ActiveRecord::Migration[7.1]
  def change
    # Add null: false constraints
    change_column_null :users, :username, false
    change_column_null :users, :email, false
    change_column_null :users, :password_digest, false
    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false

    # Add likes and dislikes with default empty arrays
    add_column :users, :likes, :text, default: "[]"
    add_column :users, :dislikes, :text, default: "[]"

    # Add unique indexes
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
  end
end