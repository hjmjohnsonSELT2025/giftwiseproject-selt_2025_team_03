class AddUserIdToGiftIdeas < ActiveRecord::Migration[7.1]
  def change
    add_reference :gift_ideas, :user, null: true, foreign_key: true
  end
end
