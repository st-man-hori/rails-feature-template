class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.date :due_date
      t.boolean :is_done, null: false, default: false

      t.timestamps
    end
  end
end
