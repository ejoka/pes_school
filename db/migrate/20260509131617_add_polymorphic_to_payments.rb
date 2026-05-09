class AddPolymorphicToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :payable_type, :string
    add_column :payments, :payable_id, :integer
  end
end
