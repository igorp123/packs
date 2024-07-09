class CreateBatches < ActiveRecord::Migration[7.1]
  def change
    create_table :batches do |t|
      t.string :number
      t.datetime :expiration_date
      t.references :drug, null: false, foreign_key: true

      t.timestamps
    end
  end
end
