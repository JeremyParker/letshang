class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.datetime :rough_time
      t.integer :owner_id
      t.string :title
      t.string :user_intro

      t.timestamps
    end
  end
end
