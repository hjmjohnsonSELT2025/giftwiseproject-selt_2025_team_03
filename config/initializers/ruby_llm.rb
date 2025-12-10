RubyLLM.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY'] || Rails.application.credentials.dig(:OPENAI_API_KEY)
  #config.default_model = "gpt-4.1-nano"
  config.default_model = "gpt-oss-120b"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
