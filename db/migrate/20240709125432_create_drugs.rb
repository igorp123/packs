class CreateDrugs < ActiveRecord::Migration[7.1]
  def change
    create_table :drugs do |t|
      t.string :name
      t.string :gtin

      t.timestamps
    end
  end
end
