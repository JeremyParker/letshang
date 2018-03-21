class FixColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :slack_id, :slack_id
  end
end
