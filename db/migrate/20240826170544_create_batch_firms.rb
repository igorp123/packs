class CreateBatchFirms < ActiveRecord::Migration[7.1]
  def change
    create_table :batch_firms do |t|
      t.belongs_to :batch, null: false, foreign_key: true
      t.belongs_to :firm, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end

    add_index :batch_firms, [:batch_id, :firm_id], unique: true
  end
end
