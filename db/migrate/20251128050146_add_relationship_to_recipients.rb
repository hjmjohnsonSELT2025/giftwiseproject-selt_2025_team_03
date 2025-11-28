class AddRelationshipToRecipients < ActiveRecord::Migration[7.1]
  def change
    add_column :recipients, :relationship, :string
  end
end
