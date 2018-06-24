class AddMeetingAddressToOption < ActiveRecord::Migration[5.1]
  def change
    add_column :options, :meeting_address, :string
  end
end
