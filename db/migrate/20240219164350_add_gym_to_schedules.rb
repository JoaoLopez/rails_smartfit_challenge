class AddGymToSchedules < ActiveRecord::Migration[6.0]
  def change
    add_reference :schedules, :gym, null: false, foreign_key: true
  end
end
