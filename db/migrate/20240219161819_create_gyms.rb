class CreateGyms < ActiveRecord::Migration[6.0]
  def change
    create_table :gyms do |t|
      t.string :name
      t.string :address
      t.boolean :opened
      t.string :mask
      t.string :towel
      t.string :fountain
      t.string :locker_room

      t.timestamps
    end
  end
end
