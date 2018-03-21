class CreateAttendance < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.integer :user_id
      t.integer :plan_id
    end
  end
end
