class RemoveOfferPlanIdFromResponses < ActiveRecord::Migration[5.1]
  def change
    remove_column :responses, :offer_plan_id, :integer
  end
end
