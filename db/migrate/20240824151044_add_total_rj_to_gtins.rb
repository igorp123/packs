class AddTotalRjToGtins < ActiveRecord::Migration[7.1]
  def change
    add_column :gtins, :total_rj, :integer
  end
end
