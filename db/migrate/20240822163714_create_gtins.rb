class CreateGtins < ActiveRecord::Migration[7.1]
  def change
    create_table :gtins do |t|
      t.string :number

      t.timestamps
    end
  end
end
