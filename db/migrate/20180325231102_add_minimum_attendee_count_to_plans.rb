class AddMinimumAttendeeCountToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :minimum_attendee_count, :integer
  end
end
