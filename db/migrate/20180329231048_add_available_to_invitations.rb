class AddAvailableToInvitations < ActiveRecord::Migration[5.1]
  def change
    add_column :invitations, :available, :boolean
  end
end
