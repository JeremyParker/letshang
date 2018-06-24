class AddDescriptionToOption < ActiveRecord::Migration[5.1]
  def change
    add_column :options, :description, :text
  end
end
