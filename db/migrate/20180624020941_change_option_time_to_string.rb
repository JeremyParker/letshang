class ChangeOptionTimeToString < ActiveRecord::Migration[5.1]
  def change
    change_column :options, :meeting_time, :string
  end
end
