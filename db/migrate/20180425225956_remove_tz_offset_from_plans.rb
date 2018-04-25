class RemoveTzOffsetFromPlans < ActiveRecord::Migration[5.1]
  def change
    remove_column :plans, :tz_offset
  end
end
