class ChatService
    attr_reader :message

    def initialize(message:)
        @message = message
    end

    def call
        # Hard code message for now
        #messages = [
        #    {role: "user", content: "Hello!"}
        #]
        
        response = client.chat(
            parameters: {
                model: "gpt-4o", # Required.
                messages: [{ role: "user", content: "Hello!"}], # Required.
                temperature: 0.7,
            }
        )
        puts response.dig("choices", 0, "message", "content")
    end

    def client
        @client ||= OpenAI::Client.new(
            access_token: ENV['open_ai_api_key'],
        )
    end
end