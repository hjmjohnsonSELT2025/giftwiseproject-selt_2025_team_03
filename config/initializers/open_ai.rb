OpenAI.configure do |config|
    config.access_token = ENV['open_ai_api_key']
    #config.openrouter_api_key = ENV['OPENROUTER_API_KEY']
    #config.default_model = "deepseek/deepseek-chat-v3-0324:free"
end