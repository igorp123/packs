class CreateFirms < ActiveRecord::Migration[7.1]
  def change
    create_table :firms do |t|
      t.string :name
      t.string :mod

      t.timestamps
    end
  end
end
