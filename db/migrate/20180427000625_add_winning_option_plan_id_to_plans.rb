class AddWinningOptionPlanIdToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :winning_option_plan_id, :integer
  end
end
