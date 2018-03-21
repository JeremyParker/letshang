class RemoveUserIdUniqueness < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :slack_id
  end
end
