class AddSlackUserNameToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :slack_user_name, :string
  end
end