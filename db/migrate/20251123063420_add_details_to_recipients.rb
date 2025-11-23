class AddDetailsToRecipients < ActiveRecord::Migration[7.1]
  def change
    add_column :recipients, :age, :integer
    add_column :recipients, :hobbies, :text
    add_column :recipients, :likes, :text
    add_column :recipients, :dislikes, :text
  end
end
