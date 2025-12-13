class Chat < ApplicationRecord
  acts_as_chat messages_foreign_key: :chat_id

  belongs_to :user
  belongs_to :event_recipient, optional:true

  validates :user, presence: true

  def ask(user_input)
    gift_schema = {
      type: 'object',
      properties: {
        title: {type: 'string'},
        price: {type: 'number'},
        status: {type: 'string'},
        url: {type: 'string'},
        notes: {
          type: 'array',
          items: {type: 'string'}
        }
      },
      required: ['title', 'price', 'status','url','notes'],
      additionalProperties: false
    }
    llm_chat = RubyLLM.chat(provider: :openrouter)
    begin
      llm_chat.with_schema(gift_schema).ask(user_input)
    rescue RubyLLM::BadRequestError => e
      Rails.logger.error "RubyLLM BadRequestError: #{e.message}"
      nil
    end
  end

end
