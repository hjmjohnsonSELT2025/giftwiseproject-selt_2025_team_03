class MakeUserIdNotNullInGiftIdeas < ActiveRecord::Migration[7.1]
  def change
    change_column_null :gift_ideas, :user_id, false
  end
end
