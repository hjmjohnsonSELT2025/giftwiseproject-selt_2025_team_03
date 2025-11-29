class MakeUserIdNotNullInGiftIdeas < ActiveRecord::Migration[7.1]
  def up
      GiftIdea.reset_column_information
      GiftIdea
      .includes(event_recipient: { recipient: :user })
      .where(user_id: nil)
      .find_each do |gift|
        user = gift.event_recipient&.recipient&.user
        if user
          gift.update_columns(user_id: user.id)
        else
          gift.destroy!
        end
      end
    change_column_null :gift_ideas, :user_id, false
  end
  def down
    change_column_null :gift_ideas, :user_id, true
  end
end
