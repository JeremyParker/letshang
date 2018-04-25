class RemoveOptionIdFromAnswers < ActiveRecord::Migration[5.1]
  def change
    remove_column :answers, :option_id
  end
end
