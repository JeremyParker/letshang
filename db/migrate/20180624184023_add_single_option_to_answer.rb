class AddSingleOptionToAnswer < ActiveRecord::Migration[5.1]
  def change
    add_column :answers, :single_option, :boolean
  end
end
