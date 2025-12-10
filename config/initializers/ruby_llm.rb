RubyLLM.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY'] || Rails.application.credentials.dig(:OPENAI_API_KEY)
  config.openrouter_api_key = ENV['OPENROUTER_API_KEY']
  #config.default_model = "gpt-4.1-nano"
  #config.default_model = "openai/gpt-oss-20b:free"
  #config.default_model = "deepseek/deepseek-chat-v3-0324:free"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
