class CreateResponses < ActiveRecord::Migration[5.1]
  def change
    create_table :responses do |t|
      t.integer :user_id
      t.integer :offer_plan_id
      t.boolean :value

      t.timestamps
    end
  end
end
