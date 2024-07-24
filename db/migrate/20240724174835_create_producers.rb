class CreateProducers < ActiveRecord::Migration[7.1]
  def change
    create_table :producers do |t|
      t.string :name
      t.string :inn

      t.timestamps
    end
  end
end
