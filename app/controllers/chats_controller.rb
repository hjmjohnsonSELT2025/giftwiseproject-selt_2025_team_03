# Controller for AI gift-suggestion chats.
class ChatsController < ApplicationController
  before_action :require_authorization

  # GET /chats/new
  # Pick an event+recipient pair and ask for gift suggestions.
  def new
    visible_event_ids = current_user.visible_events.select(:id)

    @event_recipients = EventRecipient
      .joins(:event)
      .where(events: { id: visible_event_ids })
      .includes(:event, :recipient)
      .order(Arel.sql("events.date ASC, events.id ASC"))
  end

  # GET /query_chat
  # Params:
  #   - event_recipient_id (preferred)
  #   - OR event_id + recipient_id
  #   - query
  def query
    @last_query = params[:query].to_s.strip
    @event_recipient = load_event_recipient_from_params
    return unless @event_recipient

    @event = @event_recipient.event
    @recipient = @event_recipient.recipient

    @chat = Chat.find_or_create_by!(user: current_user, event_recipient: @event_recipient)

    return if @last_query.blank?

    @chat.messages.create!(role: "user", content: @last_query)

    prompt = build_prompt(@event, @recipient, @event_recipient, @last_query)

    response = @chat.ask(prompt)
    @response_content = response

    assistant_content = extract_content(response)
    @chat.messages.create!(role: "assistant", content: assistant_content)

    @gift = parse_gift_suggestion(response)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[ChatsController#query] #{e.class}: #{e.message}")
    redirect_to new_chat_path, alert: "Unable to generate suggestion. #{e.message}"
  rescue StandardError => e
    Rails.logger.error("[ChatsController#query] #{e.class}: #{e.message}\n#{e.backtrace.first(10).join("\n")}")
    redirect_to new_chat_path, alert: "Unable to generate suggestion. Please try again."
  end

  private

  def load_event_recipient_from_params
    visible_event_ids = current_user.visible_events.select(:id)

    if params[:event_recipient_id].present?
      er = EventRecipient.includes(:event, :recipient).find_by(id: params[:event_recipient_id])
      unless er && visible_event_ids.exists?(id: er.event_id)
        redirect_to new_chat_path, alert: "Not authorized."
        return nil
      end
      return er
    end

    event_id = params[:event_id].presence
    recipient_id = params[:recipient_id].presence

    if event_id.blank? || recipient_id.blank?
      redirect_to new_chat_path, alert: "Please select an event recipient."
      return nil
    end

    event = Event.find_by(id: event_id)
    unless event && visible_event_ids.exists?(id: event.id)
      redirect_to new_chat_path, alert: "Not authorized."
      return nil
    end

    recipient = current_user.recipients.find_by(id: recipient_id)
    unless recipient
      redirect_to new_chat_path, alert: "Recipient not found."
      return nil
    end

    EventRecipient.find_or_create_by!(event: event, recipient: recipient)
  end

  def build_prompt(event, recipient, event_recipient, user_query)
    budget = event_recipient.budget.presence || event.budget

    <<~PROMPT
      You are an assistant embedded in a gift planning app.

      Task: Suggest ONE gift idea that matches the user's request.
      Requirements:
      - Keep it appropriate and realistic.
      - Prefer widely available products.
      - If a budget is provided, try to stay within it.

      Context:
      - Recipient: #{recipient.name}
      - Recipient likes: #{recipient.likes}
      - Recipient dislikes: #{recipient.dislikes}
      - Event: #{event.name}
      - Event date: #{event.date}
      - Budget: #{budget}

      User request:
      #{user_query}
    PROMPT
  end

  def extract_content(response)
    content = response.respond_to?(:content) ? response.content : response

    case content
    when Hash, Array
      content.to_json
    else
      content.to_s
    end
  end

  def parse_gift_suggestion(response)
    content = response.respond_to?(:content) ? response.content : response

    data =
      if content.is_a?(Hash)
        content
      else
        begin
          JSON.parse(content.to_s)
        rescue JSON::ParserError
          nil
        end
      end

    return nil unless data.is_a?(Hash)

    {
      title: (data["title"] || data[:title]).to_s.presence,
      price: (data["price"] || data[:price]),
      url: (data["url"] || data[:url]).to_s.presence,
      notes: (data["notes"] || data[:notes])
    }
  end
end
