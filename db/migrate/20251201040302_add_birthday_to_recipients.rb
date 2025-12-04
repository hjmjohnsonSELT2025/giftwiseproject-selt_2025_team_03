class AddBirthdayToRecipients < ActiveRecord::Migration[7.1]
  def change
    add_column :recipients, :birthday, :date
  end
end
