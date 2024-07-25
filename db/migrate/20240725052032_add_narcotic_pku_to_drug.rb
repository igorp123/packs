class AddNarcoticPkuToDrug < ActiveRecord::Migration[7.1]
  def change
    add_column :drugs, :is_narcotic, :boolean
    add_column :drugs, :is_pku, :boolean
  end
end
