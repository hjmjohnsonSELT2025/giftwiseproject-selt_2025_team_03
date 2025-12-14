class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  extend RubyLLM::ActiveRecord::ActsAs
  acts_as_chat messages_foreign_key: :chat_id

  belongs_to :user
  belongs_to :event_recipient, optional: true
end
