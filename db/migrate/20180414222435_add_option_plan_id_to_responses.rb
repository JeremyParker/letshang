class AddOptionPlanIdToResponses < ActiveRecord::Migration[5.1]
  def change
    add_column :responses, :option_plan_id, :integer
  end
end
