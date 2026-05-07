class AddProfessionalTypeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :professional_type, :string
  end
end
