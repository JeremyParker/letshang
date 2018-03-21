class CreateOptionPlan < ActiveRecord::Migration[5.1]
  def change
    create_table :option_plans do |t|
      t.integer :option_id
      t.integer :plan_id
    end
  end
end
