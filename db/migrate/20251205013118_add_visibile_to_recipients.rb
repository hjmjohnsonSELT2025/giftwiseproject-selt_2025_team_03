class AddVisibileToRecipients < ActiveRecord::Migration[7.1]
  def change
    add_column :recipients, :visible, :boolean
  end
end
