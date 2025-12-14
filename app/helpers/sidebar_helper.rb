module SidebarHelper
  def get_active_nav_item
    if current_page?(dashboard_path)
      :dashboard
    elsif controller_name == 'events' || controller_name == 'event_invitations'
      :events
    elsif current_page?(recipients_path)
      :recipients
    elsif current_page?(gift_ideas_path)
      :gift_ideas
    elsif current_page?(event_discussions_path)
      :event_discussions
    else
      :none
    end
  end
end