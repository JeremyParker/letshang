class CreateOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :options do |t|
      t.string :title
      t.datetime :meeting_time
      t.boolean :reusable

      t.timestamps
    end
  end
end
