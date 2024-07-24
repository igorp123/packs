class AddProducerToDrug < ActiveRecord::Migration[7.1]
  def change
    add_reference :drugs, :producer, null: false, foreign_key: true
  end
end
