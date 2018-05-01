class AddSucceededToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :succeeded, :boolean
  end
end
