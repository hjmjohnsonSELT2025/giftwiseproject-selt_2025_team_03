class ChatsController < ApplicationController
    def new
        @chat = Chat.new(params[:chat])
    end

    def create
    end

    def query
        @chat = Chat.find_or_initialize_by(user: current_user)
        if params[:chat].present? && params[:chat][:input].present?
            response_content = @chat.ask(params[:chat][:input])
            @response = response_content&.content
        else
            if params[:chat].present?
                flash[:alert] = "Warning: query was empty"
            end
        end
        #if params[:chat].nil?
        #    @chat = Chat.new
        #else
        #    @chat = Chat.new(query_params)
        #    if @chat.input.nil?
        #        flash[:alert] = "Warning: query was empty"
        #    end
        #end
        #render :query
    # Change later to be unique/tied to user
    #@conversation = RubyLLM.chat
    #@response = @conversation.with_schema(ChatSchema).ask (query_params)
    end

    private
    def query_params
        params.require(:chat).permit(:input)
    end
end
