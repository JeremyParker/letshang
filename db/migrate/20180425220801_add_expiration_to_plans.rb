class AddExpirationToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :expiration, :datetime
  end
end
