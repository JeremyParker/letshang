class AddTzOffsetToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :tz_offset, :integer
  end
end
