class RemoveStatusFromEventInvitations < ActiveRecord::Migration[7.1]
  def change
    remove_column :event_invitations, :status, :string
  end
end
