class AddRelationshipOtherToRecipients < ActiveRecord::Migration[7.1]
  def change
    add_column :recipients, :relationship_other, :string
  end
end
