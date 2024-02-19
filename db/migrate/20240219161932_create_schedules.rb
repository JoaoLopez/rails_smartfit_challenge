class CreateSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :schedules do |t|
      t.string :weekdays
      t.string :hour

      t.timestamps
    end
  end
end
