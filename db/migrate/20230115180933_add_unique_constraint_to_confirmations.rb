class AddUniqueConstraintToConfirmations < ActiveRecord::Migration[7.0]
  def change
    add_index :confirmations, [:confirmable_id, :confirmable_type], unique: true
  end
end
