class AddOptionPlanIdToAnswers < ActiveRecord::Migration[5.1]
  def change
    add_column :answers, :option_plan_id, :integer
  end
end
