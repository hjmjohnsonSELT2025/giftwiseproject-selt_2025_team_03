class ChatsController < ApplicationController
    def new
        @chat = Chat.new(params[:chat])
    end

    def create
    end

    def query
        @event_id = params[:event_id].to_i
        @recipient_id = params[:recipient_id].to_i
        @event_recipient_id = EventRecipient.find_or_create_by(event_id: @event_id, recipient_id: @recipient_id)
        @event = Event.find(@event_id) # For keeping form parameters
        @recipient = Recipient.find(@recipient_id) # For keeping form parameters

        if params[:chat_id].present?
            @chat = Chat.find(params[:chat_id])
        else
            @chat = Chat.find_or_initialize_by(user: current_user, event_recipient_id: @event_recipient_id.id)
            @chat.save if @chat.new_record?
        end


        # Before chat, generate response schema
        if params[:chat].present? && params[:chat][:input].present?
            #@chat.save if @chat.new_record?
            response_content = @chat.ask(params[:chat][:input])
            if !response_content
                flash[:alert] = "LLM returned an error"
            else
                @chat.messages.create!(
                    role: "assistant",
                    content: response_content.content
                )
                #@response = response_content&.content
                @response = response_content.content
            end
            
        else
            if params[:chat].present?
                flash[:alert] = "Warning: query was empty"
            end
        end
    end

    private
    def query_params
        params.require(:chat).permit(:input)
    end
end
