class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :slack_id

      t.timestamps
    end
    add_index :users, :slack_id, unique: true
  end
end
