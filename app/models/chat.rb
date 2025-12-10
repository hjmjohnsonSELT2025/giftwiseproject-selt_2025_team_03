class Chat < ApplicationRecord
  acts_as_chat messages_foreign_key: :chat_id

  belongs_to :user
  belongs_to :event_recipient, optional:true

  validates :user, presence: true

  def ask(user_input)
    llm_chat = RubyLLM.chat(provider: :openrouter, model: "deepseek/deepseek-chat-v3-0324:free")
    llm_chat.ask(user_input)
  end
end
