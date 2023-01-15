class CreateConfirmations < ActiveRecord::Migration[7.0]
  def change
    create_table :confirmations do |t|
      t.references :confirmable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
