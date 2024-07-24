class AddFieldsToTokens < ActiveRecord::Migration[7.1]
  def change
    add_column :tokens, :last_operation_time, :datetime
  end
end
