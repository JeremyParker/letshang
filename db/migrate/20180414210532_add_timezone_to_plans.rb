class AddTimezoneToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :timezone, :string
  end
end
