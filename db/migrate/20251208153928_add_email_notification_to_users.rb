class AddEmailNotificationToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :email_notifications, :boolean, default: true
  end
end
