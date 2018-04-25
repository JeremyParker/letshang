class DropTableResponses < ActiveRecord::Migration[5.1]
  def change
    drop_table :responses
  end
end
