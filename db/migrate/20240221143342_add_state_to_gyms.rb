class AddStateToGyms < ActiveRecord::Migration[6.0]
  def change
    add_column :gyms, :state, :string
  end
end
