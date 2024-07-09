class CreateSgtins < ActiveRecord::Migration[7.1]
  def change
    create_table :sgtins do |t|
      t.string :number
      t.string :status
      t.datetime :status_date
      t.datetime :last_operation_date
      t.references :drug, null: false, foreign_key: true
      t.references :batch, null: false, foreign_key: true
      t.references :firm, null: false, foreign_key: true

      t.timestamps
    end
  end
end
