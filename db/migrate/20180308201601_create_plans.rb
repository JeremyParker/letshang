class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.string :title
      t.string :created_by_slack_user

      t.timestamps
    end
  end
end
