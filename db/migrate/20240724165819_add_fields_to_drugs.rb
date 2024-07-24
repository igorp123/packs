class AddFieldsToDrugs < ActiveRecord::Migration[7.1]
  def change
    add_column :drugs, :mnn, :string
    add_column :drugs, :form_name, :string
    add_column :drugs, :form_doze, :string
  end
end
